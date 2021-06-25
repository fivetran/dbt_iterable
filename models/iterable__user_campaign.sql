with events as (

    select *
    from {{ ref('iterable__events') }}

), user_list as (

    select *
    from {{ ref('iterable__list_user_history') }}

), campaign_list as (

    select *
    from {{ ref('int_iterable__campaign_lists') }}

), pivot_out_evens as (
    email,
    campaign_id,
    campaign_name,

    recurring_campaign_id,
    recurring_campaign_name


)