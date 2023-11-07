with user_history as (
  select *
  from {{ var('user_history') }}

), latest_user as (
    select
      *,
      row_number() over(partition by unique_user_key order by updated_at desc) as latest_user_index
    from user_history
)

select *
from latest_user
where latest_user_index = 1