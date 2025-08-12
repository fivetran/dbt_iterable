{% macro get_message_type_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "channel_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "frequency_cap", "datatype": dbt.type_string()},
    {"name": "rate_limit_per_minute", "datatype": dbt.type_string()},
    {"name": "subscription_policy", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
] %}

{{ return(columns) }}

{% endmacro %}
