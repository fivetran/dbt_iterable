{{ config(enabled=var('iterable__using_user_device_history', false)) }}

with user_device_history as (
  select *
  from {{ var('user_device_history') }}

), latest_user_device as (
    select
      *,
      -- this might not be the right partitioning....
      row_number() over(partition by email, index order by updated_at desc) as latest_device_batch_index
    from user_history
)

select *
from latest_user_device
where latest_device_batch_index = 1