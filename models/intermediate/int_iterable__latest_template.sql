with template_history as (
  select *
  from {{ ref('stg_iterable__template_history') }}

), order_template as (
    select
      *,
      row_number() over(partition by template_id{{ iterable.partition_by_source_relation() }} order by updated_at desc) as latest_template_index
    from template_history

), latest_template as (

    select *
    from order_template
    where latest_template_index = 1

), message_type_channel as (

    select *
    from {{ ref('int_iterable__message_type_channel') }}

), template_join as (

    select 
        latest_template.*,
        message_type_channel.message_type_name,
        message_type_channel.channel_id,
        message_type_channel.channel_name,
        message_type_channel.channel_type,
        message_type_channel.message_medium

    from latest_template 
    left join message_type_channel
        on latest_template.message_type_id = message_type_channel.message_type_id
        and latest_template.source_relation = message_type_channel.source_relation
)

select *
from template_join