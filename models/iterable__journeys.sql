{{ config(enabled=var('iterable__using_journey', True)) }}

{%- set event_metrics = var('iterable__event_metrics') | map('lower') | list %}

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

), add_rates as (

    -- Engagement rates as a share of emails sent. Each rate is emitted only when both its
    -- numerator and denominator events are present in the `iterable__event_metrics` variable,
    -- since that list is user-configurable and may not include every email event.
    {%- set rate_expressions = [] %}
    {%- if 'emailsend' in event_metrics %}
        {%- if 'emailopen' in event_metrics %}
            {%- do rate_expressions.append('total_emailopen / nullif(total_emailsend, 0) as email_open_rate') %}
        {%- endif %}
        {%- if 'emailclick' in event_metrics %}
            {%- do rate_expressions.append('total_emailclick / nullif(total_emailsend, 0) as email_click_rate') %}
        {%- endif %}
        {%- if 'emailbounce' in event_metrics %}
            {%- do rate_expressions.append('total_emailbounce / nullif(total_emailsend, 0) as email_bounce_rate') %}
        {%- endif %}
        {%- if 'emailunsubscribe' in event_metrics %}
            {%- do rate_expressions.append('total_emailunsubscribe / nullif(total_emailsend, 0) as email_unsubscribe_rate') %}
        {%- endif %}
    {%- endif %}

    select
        *
        {% for rate in rate_expressions %}
        , {{ rate }}
        {% endfor %}

    from journey_join

), add_surrogate_key as (

    {% set surrogate_key_fields = ['journey_id', 'source_relation'] %}

    select
        *,
        {{ dbt_utils.generate_surrogate_key(surrogate_key_fields) }} as unique_journey_id

    from add_rates
)

select *
from add_surrogate_key
