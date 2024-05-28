-- These validation tests were designed to work with the pre-August 2023 version of the Iterable connector.
-- You will thus need to comment out  `iterable_user_unsubscribed_channel_identifier` and `iterable_user_unsubscribed_message_type_identifier` in the `integration_tests/dbt_project.yml` to run and validate these tests. 

{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with unsub_channels as (

    select 
        unique_user_key, 
        channel_id
    from {{ ref('stg_iterable__user_unsubscribed_channel') }}
    group by 1, 2
),

unsub_messages as (

    select 
        unique_user_key, 
        message_type_id
    from {{ ref('stg_iterable__user_unsub_message_type') }}
    group by 1, 2
),

channel_message_combos as (

    select channel_id, message_type_id 
    from {{ ref('stg_iterable__message_type') }}
    group by 1, 2
),

message_channel_unsubs as (

    select  
        unsub_channels.unique_user_key as unique_user_key_source,
        channel_message_combos.channel_id as channel_source,
        channel_message_combos.message_type_id as message_type_source
    from unsub_channels 
    inner join channel_message_combos
        on unsub_channels.channel_id = channel_message_combos.channel_id

    union all

    select 
        unsub_messages.unique_user_key as unique_user_key_source,
        channel_message_combos.channel_id as channel_source,
        channel_message_combos.message_type_id as message_type_source
    from unsub_messages
    inner join channel_message_combos
        on unsub_messages.message_type_id = channel_message_combos.message_type_id

),

source_counts as (

    select unique_user_key_source, channel_source, message_type_source, count(*) as source_count
    from message_channel_unsubs 
    group by 1, 2, 3
),

end_model_counts as (

    select unique_user_key as unique_user_key_end, channel_id as channel_end, message_type_id as message_type_end, count(*) as end_count
    from {{ ref('iterable__user_unsubscriptions') }}
    group by 1, 2, 3 
)

select * 
from source_counts
inner join end_model_counts 
    on source_counts.unique_user_key_source = end_model_counts.unique_user_key_end
where source_counts.channel_source = end_model_counts.channel_end
    and source_counts.message_type_source = end_model_counts.message_type_end
    and source_counts.source_count != end_model_counts.end_count
