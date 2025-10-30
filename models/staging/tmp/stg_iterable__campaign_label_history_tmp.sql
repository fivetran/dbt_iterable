{{ config(enabled=var('iterable__using_campaign_label_history', True)) }}

{{
    iterable.iterable_union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='campaign_label_history'
    )
}}
