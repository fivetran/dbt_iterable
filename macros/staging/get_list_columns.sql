{% macro get_list_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "list_type", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}