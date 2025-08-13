{% macro get_user_history_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "email_list_ids", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "phone_number", "datatype": dbt.type_string()},
    {"name": "signup_date", "datatype": dbt.type_timestamp()},
    {"name": "signup_source", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "user_id", "datatype": dbt.type_string()},
    {"name": "iterable_user_id", "datatype": dbt.type_string()}
    
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('iterable_user_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
