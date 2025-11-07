{% set passthrough_column_count = var('iterable_user_history_pass_through_columns') | length %}

with user_event_metrics as (

    select *
    from {{ ref('int_iterable__user_event_metrics') }}

), current_users as (

    select *
    from {{ ref('int_iterable__current_users') }}

), list_user as (

    select *
    from {{ ref('stg_iterable__list_user') }}

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

        , count(distinct list_user.list_id) as count_lists
        -- Aggregate list_ids into email_list_ids array format
        , case when count(list_user.list_id) > 0 then '[' || {{ fivetran_utils.string_agg(field_to_agg="cast(list_user.list_id as " ~ dbt.type_string() ~ ")", delimiter="', '") }} || ']' else '[]' end as email_list_ids

    from current_users
    left join list_user
        on current_users.source_relation = list_user.source_relation
        and current_users._fivetran_user_id = list_user._fivetran_list_user_id
    -- roll up to the user
    {{ dbt_utils.group_by(n = 11 + passthrough_column_count) }}

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