{% macro get_template_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "client_template_id", "datatype": dbt.type_numeric()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "creator_user_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "message_type_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "template_type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
