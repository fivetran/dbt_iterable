{{ config(
        materialized='incremental',
        unique_key='this_unique_key',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={"field": "date_day", "data_type": "date"} if target.type not in ('spark','databricks') else ['date_day'],
        file_format='delta',
        on_schema_change='fail'
    ) 
}}
-- this model will serve to extract only email-list changes
with user_history as (

    select *
    from {{ var('user_history') }} as user_history
    {% if is_incremental() %}
    where user_history.updated_at >= coalesce((select min(updated_at) from {{ this }} where is_current), '2010-01-01')
    {% endif %}

), previous_email_list_ids as (

    select
        *,
        lag(email_list_ids) over(partition by email order by updated_at asc) as previous_ids

    from user_history 

), only_new_email_list_ids as (

    select 
        email,
        user_id,
        first_name,
        last_name,
        email_list_ids,
        phone_number,
        signup_date,
        signup_source,
        updated_at

    from previous_email_list_ids
    where email_list_ids != coalesce(previous_ids, 'this is new') -- list ids are always stored in their arrays in numerical order

), most_recent_list_ids as (

    select 
        *,
        row_number() over(partition by email order by updated_at desc) as latest_user_index
    
    from only_new_email_list_ids

), final as (

    select 
        email,
        user_id,
        first_name,
        last_name,
        email_list_ids,
        phone_number,
        signup_date,
        signup_source,
        updated_at,
        latest_user_index = 1 as is_current,
        {{ dbt_utils.generate_surrogate_key(["email", "email_list_ids", "updated_at"]) }} as this_unique_key,
        cast( {{ dbt.date_trunc('day', 'updated_at') }} as date) as date_day

    from most_recent_list_ids
)

select * from final