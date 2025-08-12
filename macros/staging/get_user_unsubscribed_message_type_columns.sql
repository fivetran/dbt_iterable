{% macro get_user_unsubscribed_message_type_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "message_type_id", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
