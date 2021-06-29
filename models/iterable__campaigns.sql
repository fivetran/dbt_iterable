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

    select *
    from {{ ref('int_iterable__latest_template') }}

), campaign_join as (

    select
        campaign.*,
        campaign_list_metrics.count_send_lists,
        campaign_list_metrics.count_suppress_lists,
        {{ dbt_utils.star(from=ref('int_iterable__campaign_event_metrics'), except=['campaign_id'] if target.type != 'snowflake' else ['CAMPAIGN_ID']) }}
        , 
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
    left join campaign_list_metrics 
        on campaign.campaign_id = campaign_list_metrics.campaign_id

    {% if var('iterable__using_campaign_label_history', true) %}
    left join campaign_labels 
        on campaign.campaign_id = campaign_labels.campaign_id
    {% endif %}
    
    left join template
        on campaign.template_id = template.template_id
)

select *
from campaign_join