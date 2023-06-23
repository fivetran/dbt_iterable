{{
    config(
        materialized='incremental',
        unique_key='event_id',
        partition_by={
            "field": "created_on",
            "data_type": "date"
        } if target.type not in ['spark', 'databricks'] else ['created_on'],
        incremental_strategy = 'merge' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}

with events as (

    select *
    from {{ var('event') }}

    {% if is_incremental() %}
    where created_at >= (select max(created_at) from {{ this }} )
    {% endif %}

), campaign as (

    select *
    from {{ ref('int_iterable__recurring_campaigns') }}

), event_extension as (

    select *
    from {{ var('event_extension') }}

), users as (

    select *
    from {{ ref('int_iterable__latest_user') }}

), message_type_channel as (

    select *
    from {{ ref('int_iterable__message_type_channel') }}

), template as (

    select *
    from {{ ref('int_iterable__latest_template') }}

), event_join as (

    select 
        events.*,
        campaign.campaign_name,
        campaign.campaign_type,
        campaign.is_campaign_recurring,
        campaign.recurring_campaign_name,
        campaign.recurring_campaign_id,

        users.user_id,
        users.first_name || ' ' || users.last_name as user_full_name,

        message_type_channel.message_type_name,
        message_type_channel.message_medium,
        message_type_channel.channel_id,
        message_type_channel.channel_name,
        message_type_channel.channel_type,

        {% set exclude_fields = ["event_id", "content_id", "_fivetran_synced"] %}
        {{ dbt_utils.star(from=ref('stg_iterable__event_extension'), except= exclude_fields  ) }}
        ,
        campaign.template_id,
        template.template_name,
        template.creator_user_id as template_creator_user_id
        
    from events 
    left join event_extension 
        on events.event_id = event_extension.event_id
    left join campaign 
        on events.campaign_id = campaign.campaign_id
    left join users
        on events.email = users.email
    left join message_type_channel
        on events.message_type_id = message_type_channel.message_type_id
    left join template 
        on campaign.template_id = template.template_id
)

select *
from event_join