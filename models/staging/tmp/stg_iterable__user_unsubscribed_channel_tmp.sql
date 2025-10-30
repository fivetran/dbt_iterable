{{
    iterable.iterable_union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='user_unsubscribed_channel' if does_table_exist('user_unsubscribed_channel') else 'user_unsubscribed_channel_history'
    )
}}
