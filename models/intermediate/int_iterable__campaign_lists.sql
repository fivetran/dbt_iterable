with 

{% if var('iterable__using_campaign_suppression_list_history', True) %}

campaign_suppression_list_history as (

    select *
    from {{ var('campaign_suppression_list_history') }}

), 

{% endif %}

campaign_send_list_history as (

    select *
    from {{ var('campaign_list_history') }}

), combine_list_histories as (

{% if var('iterable__using_campaign_suppression_list_history', True) %}

    select 
        suppressed_list_id as list_id,
        campaign_id,
        updated_at,
        'suppress' as list_activity
    from campaign_suppression_list_history

    union all 

{% endif %}

    select 
        list_id,
        campaign_id,
        updated_at,
        'send' as list_activity
    from campaign_send_list_history

), order_campaign_list_history as (

    select
      *,
      row_number() over(partition by list_id, campaign_id order by updated_at desc) as latest_list_index
    from combine_list_histories

), latest_campaign_list_history as (

    select 
        list_id,
        campaign_id,
        updated_at,
        list_activity

    from order_campaign_list_history 
    where latest_list_index = 1
)

select *
from latest_campaign_list_history
