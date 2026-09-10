{{ config(enabled=var('iterable__using_journey', True)) }}

with user_campaign as (
    select *
    from {{ ref('iterable__user_campaign') }}

), campaign as (

    select
        source_relation,
        campaign_id,
        journey_id

    from {{ ref('int_iterable__recurring_campaigns') }}
    where journey_id is not null

), journey_event_metrics as (
{%- set user_campaign_columns = adapter.get_columns_in_relation(ref('iterable__user_campaign')) %}
{%- set non_agg_columns = ['source_relation', 'unique_user_key', 'user_id', '_fivetran_user_id',
    'user_email', 'user_full_name', 'campaign_id', 'campaign_name', 'recurring_campaign_id',
    'recurring_campaign_name', 'first_event_at', 'last_event_at', 'template_id', 'template_name',
    'experiment_id', 'unique_user_campaign_id', 'first_open_or_click_event_at'
    ] %}

    select
        campaign.source_relation,
        campaign.journey_id,
        count(distinct user_campaign.campaign_id) as count_total_campaigns,
        count(distinct user_campaign.unique_user_key) as count_unique_users,
        min(user_campaign.first_event_at) as first_event_at,
        max(user_campaign.last_event_at) as last_event_at
        {% for col in user_campaign_columns if col.name|lower not in non_agg_columns %}
            , sum(user_campaign.{{ col.name }}) as {{ col.name }}
            , count(distinct case when user_campaign.{{ col.name }} > 0 then user_campaign.user_email else null end) as unique_{{ col.name }}
        {% endfor %}

    from user_campaign

    inner join campaign
        on user_campaign.campaign_id = campaign.campaign_id
        and user_campaign.source_relation = campaign.source_relation

    {{ dbt_utils.group_by(n=2) }}
)

select *
from journey_event_metrics
