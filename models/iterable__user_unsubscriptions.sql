with message_type_channel as (

    select *
    from {{ ref('int_iterable__message_type_channel') }}

), user_unsubscribed_channel as (

    select
        *
    from {{ var('user_unsubscribed_channel') }}

{% if var('iterable__using_user_unsubscribed_message_type', True) %}
), user_unsubscribed_message_type as (

    select
        *
    from {{ var('user_unsubscribed_message_type') }}
{% endif %}

{% if does_table_exist('user_unsubscribed_channel') %}
), combine as (

    select 
        _fivetran_user_id,
        unique_user_key,
        channel_id,
        cast(null as {{ dbt.type_string() }}) as message_type_id
    from user_unsubscribed_channel

{% if var('iterable__using_user_unsubscribed_message_type', True) %}

{% if does_table_exist('user_unsubscribed_message_type') %}
    union all

    select 
        _fivetran_user_id,
        unique_user_key,
        cast(null as {{ dbt.type_string() }}) as channel_id,
        message_type_id
    from user_unsubscribed_message_type
{% endif %}
{% endif %}

), final as (

    select 
        combine._fivetran_user_id,
        combine.unique_user_key,
        -- coalescing since message_type -> channel goes up a grain
        coalesce(combine.channel_id, message_type_channel.channel_id) as channel_id,
        coalesce(combine.message_type_id, message_type_channel.message_type_id) as message_type_id,
        message_type_channel.channel_name,
        message_type_channel.message_type_name,
        message_type_channel.channel_type,
        message_type_channel.message_medium,
        case when combine.channel_id is not null then true else false end as is_unsubscribed_channel_wide

    from combine

    -- unsubscribing from an entire channel unsubscribes a user from all message types in that channel
    join message_type_channel 
        on combine.channel_id = message_type_channel.channel_id
        or combine.message_type_id = message_type_channel.message_type_id
)

select *
from final

{% else %}

), combine_histories as (

-- we are combining because channels are effectively parents of message types
    select 
        email,
        unique_user_key,
        channel_id,
        cast(null as {{ dbt.type_string() }}) as message_type_id,
        updated_at

    from user_unsubscribed_channel

{% if var('iterable__using_user_unsubscribed_message_type', True) %}
    union all

    select 
        email,
        unique_user_key,
        cast(null as {{ dbt.type_string() }}) as channel_id,
        message_type_id,
        updated_at
    
    from user_unsubscribed_message_type
{% endif %}

), final as (

    select
        combine_histories.email,
        combine_histories.unique_user_key,
        -- coalescing since message_type -> channel goes up a grain
        coalesce(combine_histories.channel_id, message_type_channel.channel_id) as channel_id,
        coalesce(combine_histories.message_type_id, message_type_channel.message_type_id) as message_type_id,
        message_type_channel.channel_name,
        message_type_channel.message_type_name,
        message_type_channel.channel_type,
        message_type_channel.message_medium,
        combine_histories.updated_at,
        case when combine_histories.channel_id is not null then true else false end as is_unsubscribed_channel_wide

    from combine_histories

    -- unsubscribing from an entire channel unsubscribes a user from all message types in that channel
    join message_type_channel 
        on combine_histories.channel_id = message_type_channel.channel_id
        or combine_histories.message_type_id = message_type_channel.message_type_id
)

select *
from final

{% endif %}
