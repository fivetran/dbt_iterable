with user_history as (
    select *
    from {{ ref('stg_iterable__user_history') }}

), latest_user as (
    select
        *,
        row_number() over(partition by unique_user_key{{ fivetran_utils.partition_by_source_relation(package_name='iterable') }} order by updated_at desc) as latest_user_index
    from user_history
)

select *
from latest_user
where latest_user_index = 1