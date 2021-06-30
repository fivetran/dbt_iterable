{{ config( materialized='table') }}
-- materializing as a table because the computations here are fairly complex

with user_history as (

    select * 
    from {{ ref('int_iterable__list_user_history') }}

/*
Unfortunately, `email_list_ids` are brought in as a JSON ARRAY, which different destinations handle completely differently. 
The below code serves to extract and pivot list IDs into individual rows. 
Records with an empty `email_list_ids` array will just have one row. 
*/
{% if target.type == 'redshift' %}
), numbers as (
    select 0 as generated_number
    union 
    select *
    from (
        {{ dbt_utils.generate_series(upper_bound=1000) }} )
{% endif %}
), unnest_email_array as (
    select
        email,
        first_name,
        last_name,
        user_id,
        signup_date,
        signup_source,
        phone_number,
        updated_at,
        is_current,
        email_list_ids,
        case when email_list_ids != '[]' then
        {% if target.type == 'snowflake' %}
        email_list_id.value
        {% elif target.type == 'redshift' %}
        json_extract_array_element_text(email_list_ids, cast(numbers.generated_number as {{ dbt_utils.type_int() }}), true) 
        {% else %} email_list_id
        {% endif %}
        else null end 
        as 
        email_list_id

    from user_history

    cross join 
    {% if target.type == 'snowflake' %}
        table(flatten(email_list_ids)) as email_list_id 
    {% elif target.type == 'bigquery' %}
        unnest(JSON_EXTRACT_STRING_ARRAY(email_list_ids)) as email_list_id
    {% elif target.type == 'redshift' %}
        numbers 
    where numbers.generated_number < json_array_length(email_list_ids, true)
        or (numbers.generated_number + json_array_length(email_list_ids, true) = 0)
    {% else %}
    /* postgres */
        json_array_elements_text(cast((
            case when email_list_ids = '[]' then '["is_null"]'  -- to not remove empty array-rows
            else email_list_ids end) as json)) as email_list_id
    {%- endif %}

), final as (
    select
        email,
        first_name,
        last_name,
        user_id,
        signup_date,
        signup_source,
        updated_at,
        phone_number,
        is_current,
        email_list_ids,
        cast(email_list_id as {{ dbt_utils.type_int() }}) as list_id
    from unnest_email_array
)

select *
from final