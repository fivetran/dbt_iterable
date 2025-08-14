{{
    config(
        materialized='incremental',
        unique_key='event_id',
        incremental_strategy = 'merge',
        file_format = 'delta',
        enabled=false
    )
}}

-- leave this alone for now....setting enabled to false
with events as (

    select *
    from {{ ref('stg_iterable__event') }}

    where lower(event_name) = 'customevent'
    {% if is_incremental() %}
        and updated_at > ( select max(updated_at) from {{ this }} )
    {% endif %}

), custom_events as (

    select 
        events.*
        {# {{ dbt.split_part(string_text='additional_properties', delimiter_text=' : "{', part_number=1) }} #}

        {% if target.type == 'snowflake' %}
        ,
        additional_properties.key as custom_event_name,
        additional_properties.value as custom_event_metadata
        {% endif %}
    from events

    
    {% if target.type == 'snowflake' %}
    cross join 
        table(flatten(additional_properties)) as additional_properties
    where additional_properties.key != '_id'
    {% endif %}
)

select *
from custom_events