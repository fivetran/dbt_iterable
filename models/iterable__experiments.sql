with experiment_events as (

    select *
    from {{ ref('iterable__events') }}
    where coalesce(experiment_id, null) is not null

), template as (

    select *
    from {{ ref('int_iterable__latest_template') }}

), pivot_out_events as (

    select 
        experiment_events.experiment_id,
        template.template_id,
        template.template_name,
        experiment_events.message_type_id,
        experiment_events.message_type_name,
        experiment_events.campaign_id,
        experiment_events.campaign_name,
        experiment_events.recurring_campaign_id,
        experiment_events.recurring_campaign_name,

        min(created_at) as first_event_at,
        max(created_at) as last_event_at

        -- count up the number of instances of each metric
        -- `iterable__event_metrics` is set by default to all events brought in by fivetran+iterable
        -- https://fivetran.com/docs/applications/iterable#schemanotes
        {% for em in var('iterable__event_metrics') %}
        , sum(case when lower(experiment_events.event_name) = '{{ em | lower }}' then 1 else 0 end) 
            as {{ 'total_' ~ em | replace(' ', '_') | replace('(', '') | replace(')', '') | lower }} 
        {% endfor %}

    from experiment_events
    left join campaigns
        on experiment_events.campaign_id = campaigns.campaign_id
    left join templates
        on campaigns.template_id = template.template_id
    {{ dbt_utils.group_by(n=4) }}

)

select *
from pivot_out_events