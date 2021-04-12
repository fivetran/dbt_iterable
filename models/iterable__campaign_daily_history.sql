
{{
    config(
        materialized='incremental',
        partition_by = {'field': 'date', 'data_type': 'date'},
        unique_key='campaign_day_id'
    )
}}

with campaign_metrics as (

    select * 
    from {{ ref('stg_iterable__campaign_metrics') }}

), campaign_details as (

    select * 
    from {{ ref('int_iterable__campaign_details') }}

), metric_surrogate_key as (

    select
        {{ dbt_utils.surrogate_key(['date','campaign_id']) }} as campaign_day_id,
        *
    from campaign_metrics

), campaign_enhanced as (
    select
        metric_surrogate_key.campaign_day_id,
        metric_surrogate_key.date,
        campaign_details.*,
        metric_surrogate_key.purchases,
        metric_surrogate_key.revenue,
        metric_surrogate_key.revenue_m,
        metric_surrogate_key.average_order_value,
        metric_surrogate_key.total_app_uninstalls,
        metric_surrogate_key.total_complaints,
        metric_surrogate_key.total_email_bounced,
        metric_surrogate_key.total_email_clicked,
        metric_surrogate_key.total_email_delivered,
        metric_surrogate_key.total_email_holdout,
        metric_surrogate_key.total_email_opens,
        metric_surrogate_key.total_email_send_skips,
        metric_surrogate_key.total_email_sends,
        metric_surrogate_key.total_hosted_unsubscribe_clicks,
        metric_surrogate_key.total_in_app_clicks,
        metric_surrogate_key.total_in_app_closes,
        metric_surrogate_key.total_in_app_deletes,
        metric_surrogate_key.total_in_app_holdout,
        metric_surrogate_key.total_in_app_opens,
        metric_surrogate_key.total_in_app_send_skips,
        metric_surrogate_key.total_in_app_sent,
        metric_surrogate_key.total_in_apps_delivered,
        metric_surrogate_key.total_inbox_impressions,
        metric_surrogate_key.total_purchases,
        metric_surrogate_key.total_push_holdout,
        metric_surrogate_key.total_push_send_skips,
        metric_surrogate_key.total_pushes_bounced,
        metric_surrogate_key.total_pushes_delivered,
        metric_surrogate_key.total_pushes_opened,
        metric_surrogate_key.total_pushes_sent,
        metric_surrogate_key.total_unsubscribes,
        metric_surrogate_key.unique_email_bounced,
        metric_surrogate_key.unique_email_clicks,
        metric_surrogate_key.unique_email_opens_or_clicks,
        metric_surrogate_key.unique_email_sends,
        metric_surrogate_key.unique_emails_delivered,
        metric_surrogate_key.unique_emails_opens,
        metric_surrogate_key.unique_hosted_unsubscribe_clicks,
        metric_surrogate_key.unique_in_app_clicks,
        metric_surrogate_key.unique_in_app_opens,
        metric_surrogate_key.unique_in_app_sends,
        metric_surrogate_key.unique_in_apps_delivered,
        metric_surrogate_key.unique_purchases,
        metric_surrogate_key.unique_pushes_bounced,
        metric_surrogate_key.unique_pushes_delivered,
        metric_surrogate_key.unique_pushes_opened,
        metric_surrogate_key.unique_pushes_sent,
        metric_surrogate_key.unique_unsubscribes
    from campaign_details

    left join metric_surrogate_key
        using(campaign_id)
)

select *
from campaign_enhanced

{% if is_incremental() %}

  where date >= (select max(date) from {{ this }})

{% endif %}