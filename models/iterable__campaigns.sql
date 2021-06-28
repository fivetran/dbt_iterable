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
    
), campaign_labels as (

    select *
    from {{ ref('int_iterable__campaign_labels') }}

), campaign_join as (

    select
        campaign.*,
        campaign_list_metrics.count_send_lists,
        campaign_list_metrics.count_suppress_lists,
        {{ dbt_utils.star(from=ref('int_iterable__campaign_event_metrics'), except=['campaign_id'] if target.type != 'snowflake' else ['CAMPAIGN_ID']) }}
        , campaign_labels.labels

    from campaign
    left join campaign_event_metrics 
        on campaign.campaign_id = campaign_event_metrics.campaign_id
    left join campaign_list_metrics 
        on campaign.campaign_id = campaign_list_metrics.campaign_id
    left join campaign_labels 
        on campaign.campaign_id = campaign_labels.campaign_id
)


select *
from campaign_join

-- todo: bring in template 