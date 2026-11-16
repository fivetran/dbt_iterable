{{ config(enabled=(var('iterable__using_event_extension', True) or var('iterable__using_event_webhook', True))) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='event_webhook' if var('iterable__using_event_webhook', True) else 'event_extension'
    )
}}
