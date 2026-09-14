{{ config(enabled=var('iterable__using_journey', True)) }}

with journey as (

    select *
    from {{ ref('stg_iterable__journey') }}

), journey_metrics as (

    select *
    from {{ ref('int_iterable__journey_event_metrics') }}

), journey_join as (

    {% set exclude_fields = ['source_relation', 'journey_id'] %} -- these are in journey

    -- left join so journeys that generate no events, such as audience-splitting or
    -- field-update journeys, are still reported with null metrics
    select
        journey.*,
        {{ dbt_utils.star(from=ref('int_iterable__journey_event_metrics'), except=exclude_fields, relation_alias="journey_metrics") }}

    from journey

    left join journey_metrics
        on journey.journey_id = journey_metrics.journey_id
        and journey.source_relation = journey_metrics.source_relation

), add_surrogate_key as (

    {% set surrogate_key_fields = ['journey_id', 'source_relation'] %}

    select
        *,
        {{ dbt_utils.generate_surrogate_key(surrogate_key_fields) }} as unique_journey_id

    from journey_join
)

select *
from add_surrogate_key
