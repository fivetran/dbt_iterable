with events as (

    select *
    from {{ ref('iterable__events') }}

), pivot_out_events as (

-- this will be at the user-campaign-experiment variation level
-- if experiment_id is null, the user-campaign interactions happened outside of an experiment
-- if campaign_id is null, the user interactions are organic
    select
        source_relation,
        _fivetran_user_id,
        unique_user_key,
        user_id,
        campaign_id,

        {% if var('iterable__using_event_extension', True) %}
        experiment_id,
        {% endif %}

        email as user_email,
        user_full_name,
        case when campaign_id is null then 'organic' else campaign_name end as campaign_name,
        template_id,
        template_name,

        recurring_campaign_id,
        recurring_campaign_name,

        min(created_at) as first_event_at,
        max(created_at) as last_event_at,
        min(case when event_name in ('emailOpen', 'emailClick', 'pushOpen') then created_at end) as first_open_or_click_event_at


        -- count up the number of instances of each metric
        -- `iterable__event_metrics` is set by default to all events brought in by fivetran+iterable
        -- https://fivetran.com/docs/applications/iterable#schemanotes
        {% for em in var('iterable__event_metrics') %}
        , sum(case when lower(event_name) = '{{ em | lower }}' then 1 else 0 end)
            as {{ 'total_' ~ em | replace(' ', '_') | replace('(', '') | replace(')', '') | lower }}
        {% endfor %}

    from events

    {% if var('iterable__using_event_extension', True) %}
    {{ dbt_utils.group_by(n=13) }}
    {% else %}
    {{ dbt_utils.group_by(n=12) }}
    {% endif %}

), add_surrogate_key as (

    {% set surrogate_key_fields = ['source_relation', 'unique_user_key', 'campaign_id'] %}
    {% do surrogate_key_fields.append('experiment_id') if var('iterable__using_event_extension', True) %}

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(surrogate_key_fields) }} as unique_user_campaign_id

    from pivot_out_events
)

select *
from add_surrogate_key