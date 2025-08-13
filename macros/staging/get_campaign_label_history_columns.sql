{% macro get_campaign_label_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "label", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
