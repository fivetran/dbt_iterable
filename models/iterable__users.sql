{% set passthrough_column_count = var('iterable_user_history_pass_through_columns') | length %}

with user_event_metrics as (

    select *
    from {{ ref('int_iterable__user_event_metrics') }}

), list_user_aggregated as (

    select
        source_relation,
        _fivetran_user_id,
        count(*) as count_lists,
        case when count(*) > 0
            then {{ dbt.concat(["'['", fivetran_utils.string_agg(field_to_agg="cast(list_id as " ~ dbt.type_string() ~ ")", delimiter="','"), "']'"]) }}
            else '[]'
        end as email_list_ids

    from {{ ref('stg_iterable__list_user') }}
    group by 1, 2

), user_unnested as (
    -- this has all the user fields we're looking to pass through

    select *
    from {{ ref('int_iterable__list_user_unnest') }}

    -- limit to current lists they are a member of. each list-user combo is a unique row, which we will roll up
    where is_current

), user_with_list_metrics as (

    select
        source_relation,
        user_id,
        _fivetran_user_id,
        unique_user_key,
        email,
        first_name,
        last_name,
        signup_date,
        signup_source,
        updated_at,
        phone_number,
        email_list_ids

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns') }}

        , count(distinct list_id) as count_lists

    from user_unnested
    -- roll up to the user
    {{ dbt_utils.group_by(n = 12 + passthrough_column_count) }}

), user_join as (

    select
        user_with_list_metrics.source_relation,
        user_with_list_metrics.user_id,
        user_with_list_metrics._fivetran_user_id,
        user_with_list_metrics.unique_user_key,
        user_with_list_metrics.email,
        user_with_list_metrics.first_name,
        user_with_list_metrics.last_name,
        user_with_list_metrics.signup_date,
        user_with_list_metrics.signup_source,
        user_with_list_metrics.updated_at,
        user_with_list_metrics.phone_number,
        coalesce(list_user_aggregated.email_list_ids, user_with_list_metrics.email_list_ids, '[]') as email_list_ids,
        coalesce(list_user_aggregated.count_lists, user_with_list_metrics.count_lists, '[]') as count_lists,
        {{ dbt_utils.star(from=ref('int_iterable__user_event_metrics'), except=['source_relation','unique_user_key','_fivetran_user_id','user_id','user_email']) }}

    from user_with_list_metrics
    left join user_event_metrics
        on user_with_list_metrics.unique_user_key = user_event_metrics.unique_user_key
        and user_with_list_metrics.source_relation = user_event_metrics.source_relation
    left join list_user_aggregated
        -- use _fivetran_user_id since in list_user it is a primary key
        on user_unnested._fivetran_user_id = list_user_aggregated._fivetran_user_id
        and user_unnested.source_relation = list_user_aggregated.source_relation
)

select *
from user_join