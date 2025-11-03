with user_campaign as (
    select *
    from {{ ref('iterable__user_campaign') }}

), campaign_user_event_metrics as (
{%- set using_event_extension = var('iterable__using_event_extension', True) %}
{%- set user_campaign_columns = adapter.get_columns_in_relation(ref('iterable__user_campaign')) %}
{%- set non_agg_columns = ['source_relation', 'unique_user_key', 'user_id', '_fivetran_user_id', 
    'user_email', 'user_full_name', 'campaign_id', 'campaign_name', 'recurring_campaign_id', 
    'recurring_campaign_name', 'first_event_at', 'last_event_at', 'template_id', 'template_name', 
    'experiment_id', 'unique_user_campaign_id', 'first_open_or_click_event_at'
    ] %}

    select
        source_relation,
        campaign_id,
        template_id
        {{ ", experiment_id" if using_event_extension }}
        , count(distinct unique_user_key) as count_unique_users
        {% for col in user_campaign_columns if col.name|lower not in non_agg_columns %}
            , sum({{ col.name }}) as {{ col.name }}
            , count(distinct case when {{ col.name }} > 0 then user_email else null end) as unique_{{ col.name }}
        {% endfor %}
        
    from user_campaign
    
    {{ dbt_utils.group_by(n=4 if using_event_extension else 3) }}
)

select *
from campaign_user_event_metrics
