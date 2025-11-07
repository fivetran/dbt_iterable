{{ config(
        materialized='incremental',
        unique_key='unique_key',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        partition_by={"field": "date_day", "data_type": "date"} if target.type not in ('spark','databricks') else ['date_day'],
        file_format='delta',
        on_schema_change='fail'
    )
}}

with current_users as (

    select *
    from {{ ref('int_iterable__current_users') }} as current_users

    {% if is_incremental() %}
    {# the only rows we potentially want to overwrite are active ones  #}
    where current_users.updated_at >= coalesce((select min(updated_at) from {{ this }} where is_current), '2010-01-01')
    {% endif %}

), list_user as (

    select *
    from {{ ref('stg_iterable__list_user') }}

), user_list_join as (

    select
        current_users.source_relation,
        current_users._fivetran_user_id,
        current_users.unique_user_key,
        current_users.email,
        current_users.first_name,
        current_users.last_name,
        current_users.user_id,
        current_users.signup_date,
        current_users.signup_source,
        current_users.phone_number,
        current_users.updated_at,
        current_users.is_current,
        list_user.list_id

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='current_users') }}

    from current_users
    left join list_user
        on current_users.source_relation = list_user.source_relation
        and current_users._fivetran_user_id = list_user._fivetran_list_user_id

), final as (

    select
        source_relation,
        _fivetran_user_id,
        unique_user_key,
        user_id,
        email,
        first_name,
        last_name,
        signup_date,
        signup_source,
        updated_at,
        phone_number,
        is_current,
        list_id,
        {{ dbt_utils.generate_surrogate_key(["source_relation", "unique_user_key", "list_id", "updated_at"]) }} as unique_key,
        cast( {{ dbt.date_trunc('day', 'updated_at') }} as date) as date_day

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='user_list_join') }}

    from user_list_join
)

select *
from final