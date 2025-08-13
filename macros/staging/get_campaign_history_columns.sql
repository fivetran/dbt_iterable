{% macro get_campaign_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "campaign_state", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by_user_id", "datatype": dbt.type_string()},
    {"name": "updated_by_user_id", "datatype": dbt.type_string()},
    {"name": "ended_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "recurring_campaign_id", "datatype": dbt.type_int()},
    {"name": "send_size", "datatype": dbt.type_numeric()},
    {"name": "start_at", "datatype": dbt.type_timestamp()},
    {"name": "template_id", "datatype": dbt.type_numeric()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "workflow_id", "datatype": dbt.type_numeric()},
    {"name": "message_medium", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
