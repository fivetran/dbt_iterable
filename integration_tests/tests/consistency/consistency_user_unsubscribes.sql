
{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}


with prod as (

    select 
        1 as join_key, 
        count(distinct unique_user_key) as unique_users_prod, 
        count(distinct channel_id) as channels_prod, 
        count(distinct message_type_id) as message_types_prod
    from {{ target.schema }}_iterable_prod.iterable__user_unsubscriptions
    where channel_id is not null
    and message_type_id is not null
    group by 1
),

dev as (

    select 
        1 as join_key, 
        count(distinct unique_user_key) as unique_users_dev, 
        count(distinct channel_id) as channels_dev, 
        count(distinct message_type_id) as message_types_dev
    from {{ target.schema }}_iterable_dev.iterable__user_unsubscriptions
    where channel_id is not null
    and message_type_id is not null
    group by 1
),

final as (

    select prod.join_key,
        unique_users_prod,
        unique_users_dev,
        channels_prod,
        channels_dev,
        message_types_prod,
        message_types_dev
    from prod
    full outer join dev
        on prod.join_key = dev.join_key
)    

select *
from final
where unique_users_prod != unique_users_dev
and channels_prod != channels_dev 
and message_types_prod != message_types_dev