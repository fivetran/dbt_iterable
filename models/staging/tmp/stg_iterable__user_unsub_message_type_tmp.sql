{{ config(enabled=var('iterable__using_user_unsubscribed_message_type', True)) }}

{{
    iterable.iterable_union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='user_unsubscribed_message_type' if does_table_exist('user_unsubscribed_message_type') else 'user_unsubscribed_message_type_history'
    )
}}
-- had to rename this to be compatible with postgres....