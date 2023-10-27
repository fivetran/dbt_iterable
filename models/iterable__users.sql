with user_event_metrics as (

    select *
    from {{ ref('int_iterable__user_event_metrics') }}

), user_unnested as (
    -- this has all the user fields we're looking to pass through

    select *
    from {{ ref('int_iterable__list_user_unnest') }}

    -- limit to current lists they are a member of. each list-user combo is a unique row, which we will roll up
    where is_current

), user_with_list_metrics as (

    select
        email,
        first_name,
        last_name,
        user_id,
        signup_date,
        signup_source,
        updated_at,
        phone_number,
        email_list_ids,
        count(distinct list_id) as count_lists

    from user_unnested
    -- roll up to the user
    {{ dbt_utils.group_by(n=9) }}

), user_join as (

    select 
        user_with_list_metrics.*,
        {{ dbt_utils.star(from=ref('int_iterable__user_event_metrics'), except=['user_email']) }}

    from user_with_list_metrics
    left join user_event_metrics 
        on user_with_list_metrics.email = user_event_metrics.user_email
)

select *
from user_join