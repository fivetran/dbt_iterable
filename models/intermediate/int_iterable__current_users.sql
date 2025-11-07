-- this model serves to get the most recent user history records
with user_history as (

    select *
    from {{ ref('stg_iterable__user_history') }}

), most_recent_user as (

    select
        *,
        row_number() over(partition by unique_user_key{{ iterable.partition_by_source_relation() }} order by updated_at desc) as latest_user_index

    from user_history

), final as (

    select
        source_relation,
        _fivetran_user_id,
        unique_user_key,
        email,
        user_id,
        first_name,
        last_name,
        phone_number,
        signup_date,
        signup_source,
        updated_at,
        latest_user_index = 1 as is_current

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='iterable_user_history_pass_through_columns', identifier='most_recent_user') }}

    from most_recent_user
    where latest_user_index = 1
)

select * from final