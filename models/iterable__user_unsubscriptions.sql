with message_type_channel as (

    select *
    from {{ ref('int_iterable__message_type_channel') }}

), user_unsubscribed_channel as (

    select
        *
    from {{ ref('stg_iterable__user_unsubscribed_channel') }}
    where latest_batch_index = 1

{% if var('iterable__using_user_unsubscribed_message_type', True) %}
), user_unsubscribed_message_type as (

    select
        *
    from {{ ref('stg_iterable__user_unsub_message_type') }}
    where latest_batch_index = 1

{% endif %}

), combine as (

    select
        source_relation,
        _fivetran_user_id,
        unique_user_key,
        channel_id,
        cast(null as {{ dbt.type_string() }}) as message_type_id,
        updated_at
    from user_unsubscribed_channel

{% if var('iterable__using_user_unsubscribed_message_type', True) %}

    union all

    select
        source_relation,
        _fivetran_user_id,
        unique_user_key,
        cast(null as {{ dbt.type_string() }}) as channel_id,
        message_type_id,
        updated_at
    from user_unsubscribed_message_type
{% endif %}

), final as (

    select
        combine.source_relation,
        combine._fivetran_user_id,
        combine.unique_user_key,
        -- coalescing since message_type -> channel goes up a grain
        coalesce(combine.channel_id, message_type_channel.channel_id) as channel_id,
        coalesce(combine.message_type_id, message_type_channel.message_type_id) as message_type_id,
        combine.updated_at,
        message_type_channel.channel_name,
        message_type_channel.message_type_name,
        message_type_channel.channel_type,
        message_type_channel.message_medium,
        case when combine.channel_id is not null then true else false end as is_unsubscribed_channel_wide

    from combine

    -- unsubscribing from an entire channel unsubscribes a user from all message types in that channel
    join message_type_channel
        on combine.source_relation = message_type_channel.source_relation
        and (combine.channel_id = message_type_channel.channel_id
             or combine.message_type_id = message_type_channel.message_type_id)
)

select *
from final
