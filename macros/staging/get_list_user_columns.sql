{% macro get_list_user_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "list_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}