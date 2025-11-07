with user_list_relationships as (

    select *
    from {{ ref('int_iterable__user_list_relationships') }}

), lists as (

    select * 
    from {{ ref('stg_iterable__list') }}

), final as (
    select
        user_list_relationships.source_relation,
        user_list_relationships.unique_user_key,
        user_list_relationships._fivetran_user_id,
        user_list_relationships.user_id,
        user_list_relationships.email as user_email,
        user_list_relationships.first_name as user_first_name,
        user_list_relationships.last_name as user_last_name,
        user_list_relationships.signup_date as user_signup_date,
        user_list_relationships.signup_source as user_signup_source,
        user_list_relationships.updated_at as user_updated_at,
        user_list_relationships.list_id,
        user_list_relationships.is_current,
        lists.list_name,
        lists.list_type,
        lists.created_at as list_created_at

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='user_list_relationships') }}

    from user_list_relationships
    left join lists
        on lists.source_relation = user_list_relationships.source_relation
        and lists.list_id = user_list_relationships.list_id
)

select *
from final