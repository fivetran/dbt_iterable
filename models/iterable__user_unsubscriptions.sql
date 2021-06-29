with message_type_channel as (

    select *
    from {{ ref('int_iterable__message_type_channel') }}

), user_unsubscribed_channel_history as (

    select 
        *,
        rank() over(partition by email order by updated_at desc) as latest_batch_index

    from {{ var('user_unsubscribed_channel_history') }}

), user_unsubscribed_message_type_history as (

    select 
        *,
        rank() over(partition by email order by updated_at desc) as latest_batch_index

    from {{ var('user_unsubscribed_message_type_history') }}

), combine_histories as (

    select 
        email,
        channel_id,
        null as message_type_id,
        updated_at

    from user_unsubscribed_channel_history
    where latest_batch_index = 1

    union all

    select 
        email,
        null as channel_id,
        message_type_id,
        updated_at
    
    from user_unsubscribed_message_type_history
    where latest_batch_index = 1

), final as (

    select 
        combine_histories.email,
        -- coalescing since message_type -> channel goes up a grain
        coalesce(combine_histories.channel_id, message_type_channel.channel_id) as channel_id,
        coalesce(combine_histories.message_type_id, message_type_channel.message_type_id) as message_type_id,
        message_type_channel.channel_name,
        message_type_channel.message_type_name,
        message_type_channel.channel_type,
        message_type_channel.message_medium,
        combine_histories.updated_at
        {# case when combine_histories.message_type_id is null then 'all' 
            else message_type_channel.message_type_name end as message_type_name #}

    from combine_histories

    join message_type_channel 
        on combine_histories.channel_id = message_type_channel.channel_id
        or combine_histories.message_type_id = message_type_channel.message_type_id
)

select *
from final
