{{ config(enabled=var('iterable__using_user_device_history', false)) }}

with user_device_history as (
    select *
    from {{ var('user_device_history') }}

), order_user_devices as (
    select
      *,
      rank() over(partition by email order by updated_at desc) as latest_device_batch_index
    from user_device_history

), latest_user_device as (

    select *
    from order_user_devices
    where latest_device_batch_index = 1

), count_devices as (

    select
      email,
      count(distinct platform_endpoint) as count_devices
    
    from latest_user_device

    group by 1
)

select *
from count_devices
