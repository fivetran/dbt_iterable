with user_list_unnest as (

    select * 
    from {{ ref('int_iterable__list_user_unnest') }}

), lists as (

    select * 
    from {{ var('list') }}

), final as (
    select
        user_list_unnest.unique_user_key,
        user_list_unnest._fivetran_user_id,
        user_list_unnest.user_id,
        user_list_unnest.email as user_email,
        user_list_unnest.first_name as user_first_name,
        user_list_unnest.last_name as user_last_name,
        user_list_unnest.signup_date as user_signup_date,
        user_list_unnest.signup_source as user_signup_source,
        user_list_unnest.updated_at as user_updated_at,
        user_list_unnest.list_id,
        user_list_unnest.is_current,
        lists.list_name,
        lists.list_type,
        lists.created_at as list_created_at   

    from user_list_unnest
    left join lists
        on lists.list_id = user_list_unnest.list_id
)

select *
from final