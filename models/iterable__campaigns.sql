with campaign_event_metrics as (

    select *
    from {{ ref('int_iterable__campaign_event_metrics') }}

), campaign_list_metrics as (

    select
        campaign_id,
        sum(case when list_activity = 'send' then 1 else 0 end) as count_send_lists,
        sum(case when list_activity = 'suppress' then 1 else 0 end) as count_suprress_lists
    
    from {{ var('int_iterable__campaign_lists') }}
    group by campaign_id

), campaign as (

    select *
    from {{ ref('int_iterable__recurring_campaigns') }}
    
), campaign_labels as (

    select 

    from {{ }} -- left off here
)