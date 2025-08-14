{{ config(enabled=var('iterable__using_event_extension', True)) }}

select * 
from {{ var('event_extension') }}
