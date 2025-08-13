{% macro get_campaign_suppression_list_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "suppressed_list_id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
