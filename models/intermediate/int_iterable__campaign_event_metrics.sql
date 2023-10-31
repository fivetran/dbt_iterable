with user_campaign as (

    select *
    from {{ ref('iterable__user_campaign') }}

), campaign_user_event_metrics as (

{%- set user_campaign_columns = adapter.get_columns_in_relation(ref('iterable__user_campaign')) %}

    select
        campaign_id,
        template_id,
        experiment_id,
        count(distinct unique_user_key) as count_unique_users
        {% for col in user_campaign_columns %}
            {% if col.name|lower not in ['unique_user_key', 'user_id', '_fivetran_user_id', 'user_email', 'user_full_name', 'campaign_id', 'campaign_name', 'recurring_campaign_id', 
                                        'recurring_campaign_name', 'first_event_at', 'last_event_at', 'template_id', 'template_name',
                                        'experiment_id'] %}
            , sum( {{ col.name }} ) as {{ col.name }}
            , count(distinct case when {{ col.name }} > 0 then user_email else null end) as {{ 'unique_' ~ col.name }}
            {% endif %}
        {% endfor -%}

    from user_campaign
    group by 1,2,3

)

select *
from campaign_user_event_metrics