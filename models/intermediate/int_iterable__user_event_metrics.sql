with user_campaign as (

    select *
    from {{ ref('iterable__user_campaign') }}

), user_event_metrics as (

{%- set user_campaign_columns = adapter.get_columns_in_relation(ref('iterable__user_campaign')) %}

    select
        user_email, 
        count(distinct campaign_id) as count_total_campaigns,
        min(first_event_at) as first_event_at,
        max(last_event_at) as last_event_at

        {% for col in user_campaign_columns %}
            {% if col.name|lower not in ['user_email', 'user_full_name', 'campaign_id', 'campaign_name', 'recurring_campaign_id', 
                                        'recurring_campaign_name', 'first_event_at', 'last_event_at', 'template_id', 'template_name',
                                        'experiment_id'] %}
        , sum( {{ col.name }} ) as {{ col.name }}
            {% endif %}
        {% endfor -%}

    from user_campaign
    group by user_email

)

select *
from user_event_metrics