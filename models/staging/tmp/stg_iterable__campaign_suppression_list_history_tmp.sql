{{ config(enabled=var('iterable__using_campaign_suppression_list_history', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='iterable_sources',
        single_source_name='iterable',
        single_table_name='campaign_suppression_list_history'
    )
}}
