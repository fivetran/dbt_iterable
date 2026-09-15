{% macro get_journey_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "creator_user_id", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "enabled", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "is_archived", "datatype": "boolean"},
    {"name": "journey_type", "datatype": dbt.type_string()},
    {"name": "lifetime_limit", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "simultaneous_limit", "datatype": dbt.type_int()},
    {"name": "start_tile_id", "datatype": dbt.type_int()},
    {"name": "trigger_event_names", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('iterable_journey_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
