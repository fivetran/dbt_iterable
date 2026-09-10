{{ config(enabled=var('iterable__using_journey', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='journey'
    )
}}
