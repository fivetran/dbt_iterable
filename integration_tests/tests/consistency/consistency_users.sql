{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}
-- this test ensures the iterable__users end model matches the prior version
with prod as (
    select *
    from {{ target.schema }}_iterable_prod.iterable__users
    where date(created_at) < date({{ dbt.current_timestamp() }})
),

dev as (
    select *
    from {{ target.schema }}_iterable_dev.iterable__users
    where date(created_at) < date({{ dbt.current_timestamp() }})
),

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final
