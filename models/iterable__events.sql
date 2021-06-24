{{
    config(
        materialized='incremental',
        unique_key='event_id',
        partition_by={
            "field": "created_on",
            "data_type": "date"
        } if target.type == 'bigquery' else none,
        incremental_strategy = 'merge',
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

), user as (

    select *
    from {{ ref('int_iterable__latest_user') }}

), message_type as (

    select *
    from {{ var('message_type') }}

), channel as (

    select *
    from {{ var('channel') }}

), event_join as (

    select 
        events.*,
        campaign.campaign_name,
        campaign.campaign_type,
        campaign.is_campaign_recurring,
        campaign.recurring_campaign_name,
        campaign.recurring_campaign_id,

        user.user_id,
        user.first_name || ' ' || user.last_name as user_full_name,

        message_type.message_type_name,
        channel.message_medium,
        message_type.channel_id,
        channel.channel_name,
        channel.channel_type,

        {% set exclude_fields = ["event_id", "content_id", "_fivetran_synced"] %}
        {{ dbt_utils.star(from=ref('stg_iterable__event_extension'), except= exclude_fields | upper if target.type == 'snowflake' else exclude_fields ) }}
        
    from events 
    left join event_extension 
        on events.event_id = event_extension.event_id
    left join campaign 
        on events.campaign_id = campaign.campaign_id
    left join user 
        on events.email = user.email
    left join message_type
        on events.message_type_id = message_type.message_type_id
    left join channel
        on message_type.channel_id = channel.channel_id
)

select *
from event_join