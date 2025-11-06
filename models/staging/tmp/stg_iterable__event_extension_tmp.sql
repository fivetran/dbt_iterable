{{ config(enabled=var('iterable__using_event_extension', True)) }}

{{
    iterable.iterable_union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='event_extension'
    )
}}
