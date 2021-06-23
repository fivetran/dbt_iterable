{{
    config(
        materialized='incremental',
        unique_key='_fivetran_event_id',
        partition_by={
            "field": "occurred_on",
            "data_type": "date"
        } if target.type == 'bigquery' else none,
        incremental_strategy = 'merge',
        file_format = 'delta'
    )
}}

with events as (

    select 
        *,

    from {{ var('event') }}

    {% if is_incremental() %}
    -- grab **ALL** events for users who have any events in this new increment
    where email in (

        select distinct email
        from {{ var('event') }}

        -- look back an hour in case of delay in events getting sent to the warehouse
        where _fivetran_synced >= cast(coalesce( 
            (
                select {{ dbt_utils.dateadd(datepart = 'hour', 
                                            interval = -1,
                                            from_date_or_timestamp = 'max(_fivetran_synced)' ) }}  
                from {{ this }}
            ), '2013-01-01') as {{ dbt_utils.type_timestamp() }} ) -- iterable was founded in 2013, so let's default the min date to then
    )
    {% endif %}

), event_extension as (

    select *
    from {{ var('event_extension') }}

), custom_event_names

