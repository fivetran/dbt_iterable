with template_history as (
  select *
  from {{ var('template_history') }}

), order_template as (
    select
      *,
      row_number() over(partition by template_id order by updated_at desc) as latest_template_index
    from template_history

), latest_template as (

    select *
    from order_template
    where latest_template_index = 1

), message_type as (

    select *
    from {{ var('message_type') }}

), channel as (

    select * 
    from {{ var('channel') }}

), template_join as (

    select 
        latest_template.*,
        message_type.message_type_name,
        message_type.channel_id,
        channel.channel_name,
        channel.channel_type,
        channel.message_medium

    from latest_template 
    left join message_type 
        on latest_template.message_type_id = message_type.message_type_id
    left join channel 
        on message_type.channel_id = channel.channel_id
)

select *
from template_join