{% macro get_channel_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "channel_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "message_medium", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
