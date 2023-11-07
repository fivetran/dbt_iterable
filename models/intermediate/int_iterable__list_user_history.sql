-- this model will serve to extract only email-list changes
with user_history as (

    select *
    from {{ var('user_history') }}
    where email is not null -- add a not-null filter because some users may not have an associated email, but this model is only for email lists

), previous_email_list_ids as (

    select
        *,
        lag(email_list_ids) over(partition by email order by updated_at asc) as previous_ids -- partition by email instead of unique_user_key here since this model is only for email-list users

    from user_history 

), only_new_email_list_ids as (

    select
        _fivetran_user_id,
        unique_user_key,
        user_id,
        email,
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
        _fivetran_user_id,
        unique_user_key,
        email,
        user_id,
        first_name,
        last_name,
        email_list_ids,
        phone_number,
        signup_date,
        signup_source,
        updated_at,
        latest_user_index = 1 as is_current

    from most_recent_list_ids
)

select * from final