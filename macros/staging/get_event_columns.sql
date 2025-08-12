{% macro get_event_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_user_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "content_id", "datatype": dbt.type_numeric()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "event_name", "datatype": dbt.type_string()},
    {"name": "message_bus_id", "datatype": dbt.type_string()},
    {"name": "message_id", "datatype": dbt.type_string()},
    {"name": "message_type_id", "datatype": dbt.type_int()},
    {"name": "recipient_state", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "unsub_source", "datatype": dbt.type_string()},
    {"name": "user_agent", "datatype": dbt.type_string()},
    {"name": "user_agent_device", "datatype": dbt.type_string()},
    {"name": "transactional_data", "datatype": dbt.type_string()},
    {"name": "additional_properties", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}