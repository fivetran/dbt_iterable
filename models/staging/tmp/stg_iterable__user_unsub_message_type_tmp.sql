{{ config(enabled=var('iterable__using_user_unsubscribed_message_type', True)) }}

select *
from {{ var('user_unsubscribed_message_type') if does_table_exist('user_unsubscribed_message_type') else var('user_unsubscribed_message_type_history') }}
-- had to rename this to be compatible with postgres....