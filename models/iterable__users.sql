{% set passthrough_column_count = var('iterable_user_history_pass_through_columns') | length %}

with user_event_metrics as (

    select *
    from {{ ref('int_iterable__user_event_metrics') }}

), old_method_user_lists as (
    -- Old method: from email_list_ids in user_history (unnested)
    select *
    from {{ ref('int_iterable__list_user_unnest') }}
    where is_current

), new_method_user_lists as (
    -- New method: from list_user table
    select *
    from {{ ref('int_iterable__user_list_relationships') }}
    where is_current

), current_users as (
    -- Get all current users from user_history
    select *
    from {{ ref('int_iterable__current_users') }}

), combined_user_lists as (
    -- Union both methods, prioritizing new method when both exist for the same user
    select * from new_method_user_lists

    union all

    select * from old_method_user_lists
    where unique_user_key not in (select unique_user_key from new_method_user_lists)

), user_lists_aggregated as (
    -- Pre-aggregate list data per user to avoid DISTINCT + LISTAGG conflict
    select
        source_relation,
        unique_user_key,
        count(*) as count_lists,
        case when count(*) > 0
             then '[' || {{ fivetran_utils.string_agg(field_to_agg="cast(list_id as " ~ dbt.type_string() ~ ")", delimiter="', '") }} || ']'
             else '[]'
        end as email_list_ids
    from combined_user_lists
    where is_current and list_id is not null
    group by 1, 2

), user_with_list_metrics as (

    select
        current_users.source_relation,
        current_users.user_id,
        current_users._fivetran_user_id,
        current_users.unique_user_key,
        current_users.email,
        current_users.first_name,
        current_users.last_name,
        current_users.signup_date,
        current_users.signup_source,
        current_users.updated_at,
        current_users.phone_number

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='current_users') }}

        , coalesce(user_lists_aggregated.count_lists, 0) as count_lists
        , coalesce(user_lists_aggregated.email_list_ids, '[]') as email_list_ids

    from current_users
    left join user_lists_aggregated
        on current_users.source_relation = user_lists_aggregated.source_relation
        and current_users.unique_user_key = user_lists_aggregated.unique_user_key

), user_join as (

    select
        user_with_list_metrics.*,
        {{ dbt_utils.star(from=ref('int_iterable__user_event_metrics'), except=['source_relation','unique_user_key','_fivetran_user_id','user_id','user_email']) }}

    from user_with_list_metrics
    left join user_event_metrics
        on user_with_list_metrics.unique_user_key = user_event_metrics.unique_user_key
        and user_with_list_metrics.source_relation = user_event_metrics.source_relation
)

select *
from user_join