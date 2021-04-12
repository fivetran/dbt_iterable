with latest_user as (

    select * 
    from {{ ref('int_iterable__latest_user') }}

), user_table_array as (
    select
        *,
        {{ fivetran_utils.json_extract("email_list_ids", "", json_type="array") }} as list_array_id
    from latest_user

), final as (
    select
        email,
        first_name,
        last_name,
        user_id,
        signup_date,
        signup_source,
        updated_at,
        cast(list_value_id as {{ dbt_utils.type_int() }} ) as list_id
    from user_table_array

    cross join unnest(list_array_id) list_value_id
)

select *
from final