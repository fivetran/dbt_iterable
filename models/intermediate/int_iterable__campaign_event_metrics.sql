with user_campaign as (

    select *
    from {{ ref('iterable__user_campaign') }}

), campaign_lists as (

    select *
    from {{ ref('int_iterable__campaign_lists') }}

), campaign_list_metrics as (

    select
        campaign_id,
        sum(case when list_activity = 'send' then 1 else 0 end) as count_send_lists,
        sum(case when list_activity = 'suppress' then 1 else 0 end) as count_suprress_lists
    
    from campaign_lists
    group by campaign_id
        
), campaign_user_event_metrics as (

{%- set user_campaign_columns = adapter.get_columns_in_relation(ref('iterable__user_campaign')) %}

    select
        campaign_id, 
        count(distinct user_email) as count_unique_users,
        {% for col in user_campaign_columns %}
            {% if col.name|lower not in ['user_email', 'user_full_name', 'campaign_id', 'campaign_name', 'recurring_campaign_id', 
                                        'recurring_campaign_name'] %}
        , sum( {{ col.name }} ) as {{ col.name }}
        , sum(case when {{ col.name }} > 0 then 1 else 0 end) as {{ 'unique_' ~ col.name }}

            {% endif %}
        {% endfor -%}

    from user_campaign
)