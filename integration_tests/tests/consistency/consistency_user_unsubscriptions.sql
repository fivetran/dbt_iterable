{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

{% set exclude_cols = var('consistency_test_exclude_metrics', []) %}
{% set fields = dbt_utils.star(from=ref('iterable__user_unsubscriptions'), except=exclude_cols) %}

-- this test ensures the iterable__user_unsubscriptions end model matches the prior version
with prod as (
    select {{ fields }}
    from {{ target.schema }}_iterable_prod.iterable__user_unsubscriptions
),

dev as (
    select {{ fields }}
    from {{ target.schema }}_iterable_dev.iterable__user_unsubscriptions
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
