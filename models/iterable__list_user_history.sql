-- Union both old method (email_list_ids unnesting) and new method (list_user table)
with old_method as (
    -- Old method: from email_list_ids in user_history
    select *
    from {{ ref('int_iterable__list_user_unnest') }}
    where is_current and list_id is not null

), new_method as (
    -- New method: from list_user table
    select *
    from {{ ref('int_iterable__user_list_relationships') }}
    where is_current and list_id is not null

), combined_user_lists as (
    -- Combine both methods, prioritizing new method when both exist for the same user
    select * from new_method

    union all

    select * from old_method
    where unique_user_key not in (select unique_user_key from new_method)

), lists as (

    select *
    from {{ ref('stg_iterable__list') }}

), final as (
    select
        combined_user_lists.source_relation,
        combined_user_lists.unique_user_key,
        combined_user_lists._fivetran_user_id,
        combined_user_lists.user_id,
        combined_user_lists.email as user_email,
        combined_user_lists.first_name as user_first_name,
        combined_user_lists.last_name as user_last_name,
        combined_user_lists.signup_date as user_signup_date,
        combined_user_lists.signup_source as user_signup_source,
        combined_user_lists.updated_at as user_updated_at,
        combined_user_lists.list_id,
        combined_user_lists.is_current,
        lists.list_name,
        lists.list_type,
        lists.created_at as list_created_at

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='combined_user_lists') }}

    from combined_user_lists
    left join lists
        on lists.source_relation = combined_user_lists.source_relation
        and lists.list_id = combined_user_lists.list_id
)

select *
from final