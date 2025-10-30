{{ config(enabled=var('iterable__using_campaign_label_history', True)) }}

with campaign_label_history as (

    select *
    from {{ ref('stg_iterable__campaign_label_history') }}

), order_campaign_labels as (

    select 
        *,
        rank() over(partition by campaign_id{{ iterable.partition_by_source_relation() }} order by updated_at desc) as latest_label_batch_index

    from campaign_label_history

), latest_labels as (

    select *
    from order_campaign_labels
    where latest_label_batch_index = 1

), aggregate_labels as (

    select
        source_relation,
        campaign_id,
        {{ fivetran_utils.string_agg('distinct label', "', '") }} as labels

    from latest_labels
    group by source_relation, campaign_id
)

select * from aggregate_labels