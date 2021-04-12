with latest_campaign as (

    select * 
    from {{ ref('int_iterable__latest_campaign') }}

), recurring_campaign_join as (
     select
        latest_campaign.campaign_id,
        latest_campaign.campaign_name,
        case when latest_campaign.recurring_campaign_id is null
            then true
            else false
                end as is_recurring_campaign,
        case when latest_campaign.recurring_campaign_id is null
            then latest_campaign.campaign_id
            else latest_campaign.recurring_campaign_id
                end as recurring_campaign_id,
        case when latest_campaign.recurring_campaign_id is null
            then latest_campaign.campaign_name
            else recurring_campaign.campaign_name
                end as recurring_campaign_name,
        latest_campaign.updated_at,
        latest_campaign.campaign_state,
        latest_campaign.type,
        latest_campaign.send_size,
        latest_campaign.start_at,
        latest_campaign.ended_at,
        latest_campaign.created_at,
        latest_campaign.created_by_user_id,
        latest_campaign.template_id

    from latest_campaign

    left join latest_campaign as recurring_campaign
        on latest_campaign.recurring_campaign_id = recurring_campaign.campaign_id
)

select *
from recurring_campaign_join