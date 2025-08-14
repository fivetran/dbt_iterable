select *
from {{ var('user_unsubscribed_channel') if does_table_exist('user_unsubscribed_channel') else var('user_unsubscribed_channel_history') }}
