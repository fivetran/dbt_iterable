{{ config(enabled=var('iterable__using_user_device_history', True)) }}

with user_device_history as (
  select *
  from {{ ref('stg_iterable__user_device_history') }}

), latest_user_device as (
    select
      *,
      row_number() over(partition by email, index, updated_at order by updated_at desc) as latest_device_batch_index
    from user_history
)

select *
from latest_user_device
where latest_device_batch_index = 1