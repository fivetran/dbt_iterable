with campaign_event_metrics as (

    select *
    from {{ ref('int_iterable__campaign_event_metrics') }}

), campaign_list_metrics as (

    select
        campaign_id,
        sum(case when list_activity = 'send' then 1 else 0 end) as count_send_lists,
        sum(case when list_activity = 'suppress' then 1 else 0 end) as count_suppress_lists
    
    from {{ ref('int_iterable__campaign_lists') }}
    group by campaign_id

), campaign as (

    select *
    from {{ ref('int_iterable__recurring_campaigns') }}
    
{% if var('iterable__using_campaign_label_history', true) %}
), campaign_labels as (

    select *
    from {{ ref('int_iterable__campaign_labels') }}

{% endif %}

), template as (
    -- rebringing this in (it is brought in iterable__events) in case any campaigns don't have events yet
    -- this will result in some DAG ugliness but maintains template info for non-sent campaigns
    select *
    from {{ ref('int_iterable__latest_template') }}

), campaign_join as (

    {% set exclude_fields = [ 'campaign_id', 'template_id'] %} -- these are both in campaigns

    -- this query will be at the campaign and experiment(if available) variation grain
    select
        campaign.*,
        {{ dbt_utils.star(from=ref('int_iterable__campaign_event_metrics'), except=exclude_fields) }}
        , 
        campaign_list_metrics.count_send_lists,
        campaign_list_metrics.count_suppress_lists,
        {% if var('iterable__using_campaign_label_history', true) %}
        campaign_labels.labels,
        {% endif %}
        template.template_name,
        template.creator_user_id as template_creator_user_id,
        template.message_medium,
        template.message_type_name,
        template.channel_name,
        template.channel_id,
        template.channel_type

    from campaign
    left join campaign_event_metrics 
        on campaign.campaign_id = campaign_event_metrics.campaign_id
        and campaign.template_id = campaign_event_metrics.template_id
    left join campaign_list_metrics 
        on campaign.campaign_id = campaign_list_metrics.campaign_id

    {% if var('iterable__using_campaign_label_history', true) %}
    left join campaign_labels 
        on campaign.campaign_id = campaign_labels.campaign_id
    {% endif %}
    
    left join template
        on campaign.template_id = template.template_id

), add_surrogate_key as (

    {% set surrogate_key_fields = ['campaign_id', 'template_id'] %}
    {% do surrogate_key_fields.append('experiment_id') if var('iterable__using_event_extension', True) %}

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(surrogate_key_fields) }} as campaign_version_id

    from campaign_join
)

select *
from add_surrogate_key