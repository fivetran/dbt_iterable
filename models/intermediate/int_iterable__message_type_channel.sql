with message_type as (

    select *
    from {{ var('message_type') }}

), channel as (

    select *
    from {{ var('channel') }}

), final as (

    select 
        channel.*,
        message_type.message_type_name,
        message_type.message_type_id
    from channel
    left join message_type on channel.channel_id = message_type.channel_id
)

select *
from final