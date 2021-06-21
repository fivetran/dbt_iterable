with latest_user as (

    select * 
    from {{ ref('int_iterable__latest_user') }}

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
        updated_at,
        case when json_array_length(email_list_ids, true) > 0 then
        {% if target.type == 'snowflake' %}
        email_list_id.value
        {% elif target.type == 'redshift' %}
        json_extract_array_element_text(email_list_ids, cast(numbers.generated_number as {{ dbt_utils.type_int() }}), true) 
        {% else %} email_list_id
        {% endif %}
        else null {{ log('twas null', info=true) }} end 
        as 
        email_list_id
        , numbers.generated_number

    from latest_user

    cross join 
    {% if target.type == 'snowflake' %}
        table(flatten(email_list_ids)) as email_list_id 
    {% elif target.type == 'bigquery' %}
        unnest(JSON_EXTRACT_STRING_ARRAY(email_list_ids)) as email_list_id
    {% elif target.type == 'redshift' %}
        numbers 
    where numbers.generated_number < json_array_length(email_list_ids, true)
        or (numbers.generated_number + json_array_length(email_list_ids, true) = 0)
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
        cast(email_list_id as {{ dbt_utils.type_int() }}) as email_list_id,
        generated_number
    from unnest_email_array
)

select *
from final