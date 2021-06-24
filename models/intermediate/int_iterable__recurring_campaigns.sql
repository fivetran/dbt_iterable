with latest_campaign as (

    select * 
    from {{ ref('int_iterable__latest_campaign') }}

), recurring_campaign_join as (
     select
        latest_campaign.campaign_id,
        latest_campaign.campaign_name,

        latest_campaign.updated_at,
        latest_campaign.campaign_state,
        latest_campaign.campaign_type,
        latest_campaign.send_size,
        latest_campaign.start_at,
        latest_campaign.ended_at,
        latest_campaign.created_at,
        latest_campaign.created_by_user_id,
        latest_campaign.template_id,
        latest_campaign.recurring_campaign_id,

        recurring_campaign.campaign_name as recurring_campaign_name,
        recurring_campaign.campaign_state as recurring_campaign_state,
        recurring_campaign.send_size as recurring_campaign_send_size,
        recurring_campaign.start_at as recurring_campaign_start_at

    from latest_campaign

    left join latest_campaign as recurring_campaign
        on latest_campaign.recurring_campaign_id = recurring_campaign.campaign_id

), final as (

    select
        recurring_campaign_join.*,
        case when latest_campaign.recurring_campaign_id is not null then true 
        else false end as is_campaign_recurring

    from recurring_campaign_join
    left join latest_campaign on recurring_campaign_join.campaign_id = latest_campaign.recurring_campaign_id
)

select *
from final