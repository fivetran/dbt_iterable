with events as (

    select *
    from {{ ref('iterable__events') }}

), pivot_out_events as (

    select 
        email as user_email,
        user_full_name,
        campaign_id,
        campaign_name,

        recurring_campaign_id,
        recurring_campaign_name,

        min(created_at) as first_event_at,
        max(created_at) as last_event_at

        -- count up the number of instances of each metric
        -- `iterable__event_metrics` is set by default to all events brought in by fivetran+iterable
        -- https://fivetran.com/docs/applications/iterable#schemanotes
        {% for em in var('iterable__event_metrics') %}
        , sum(case when lower(event_name) = '{{ em | lower }}' then 1 else 0 end) 
            as {{ 'total_' ~ em | replace(' ', '_') | replace('(', '') | replace(')', '') | lower }} 
        {% endfor %}

    from events
    group by 1,2,3,4,5,6

)

select *
from pivot_out_events