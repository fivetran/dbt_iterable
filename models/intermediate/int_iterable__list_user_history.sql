-- this model will serve to extract only email-list changes
-- should perhaps be incremental...takes 2 min on our data
with user_history as (

    select *
    from {{ var('user_history') }}

), previous_email_list_ids as (

    select
        *,
        lag(email_list_ids) over(partition by email order by updated_at asc) as previous_email_list_ids

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
    where email_list_ids != previous_email_list_ids -- list ids are always stored in their arrays in numerical order
)

select * from only_new_email_list_ids