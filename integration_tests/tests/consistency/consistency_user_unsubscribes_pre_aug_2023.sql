-- These validation tests were designed to work with the pre-August 2023 version of the Iterable connector.
-- You will thus need to comment out  `iterable_user_unsubscribed_channel_identifier` and `iterable_user_unsubscribed_message_type_identifier` in the `integration_tests/dbt_project.yml` to run and validate these tests. 

{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}


with prod as (

    select 
        unique_user_key, 
        coalesce(count(distinct unique_user_key), 0) as unique_user_records_prod, 
        coalesce(count(distinct channel_id), 0) as channels_prod, 
        coalesce(count(distinct message_type_id), 0) as message_types_prod
    from {{ target.schema }}_iterable_prod.iterable__user_unsubscriptions
    where channel_id is not null
        and message_type_id is not null
    group by 1
),

dev as (

    select 
        unique_user_key, 
        coalesce(count(distinct unique_user_key), 0) as unique_user_records_dev, 
        coalesce(count(distinct channel_id), 0) as channels_dev, 
        coalesce(count(distinct message_type_id), 0) as message_types_dev
    from {{ target.schema }}_iterable_dev.iterable__user_unsubscriptions
    where channel_id is not null
        and message_type_id is not null
    group by 1
),

final as (

    select 
        prod.unique_user_key,
        unique_user_records_prod,
        unique_user_records_dev,
        channels_prod,
        channels_dev,
        message_types_prod,
        message_types_dev
    from prod
    full outer join dev
        on prod.unique_user_key = dev.unique_user_key
)    

select *
from final
where unique_user_records_prod != unique_user_records_dev
    and channels_prod != channels_dev 
    and message_types_prod != message_types_dev