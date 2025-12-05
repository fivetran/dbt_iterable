with user_history_unnest as (

    select *
    from {{ ref('int_iterable__list_user_unnest') }}

), list_users as (

    select *
    from {{ ref('stg_iterable__list_user') }}

), lists as (

    select *
    from {{ ref('stg_iterable__list') }}

), final as (
    select distinct
        user_history_unnest.source_relation,
        user_history_unnest.unique_user_key,
        user_history_unnest._fivetran_user_id,
        user_history_unnest.user_id,
        user_history_unnest.email as user_email,
        user_history_unnest.first_name as user_first_name,
        user_history_unnest.last_name as user_last_name,
        user_history_unnest.signup_date as user_signup_date,
        user_history_unnest.signup_source as user_signup_source,
        user_history_unnest.updated_at as user_updated_at,
        coalesce(list_users.list_id, user_history_unnest.list_id) as list_id,
        user_history_unnest.is_current,
        lists.list_name,
        lists.list_type,
        lists.created_at as list_created_at

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='user_history_unnest') }}

    from user_history_unnest
    left join list_users
        on list_users.source_relation = user_history_unnest.source_relation
        and list_users._fivetran_user_id = user_history_unnest._fivetran_user_id
    left join lists
        on lists.source_relation = user_history_unnest.source_relation
        and lists.list_id = coalesce(list_users.list_id, user_history_unnest.list_id)
)

select *
from final