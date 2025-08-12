{% macro get_event_extension_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_already_running", "datatype": "boolean"},
    {"name": "badge", "datatype": dbt.type_string()},
    {"name": "catalog_collection_count", "datatype": dbt.type_numeric()},
    {"name": "catalog_lookup_count", "datatype": dbt.type_numeric()},
    {"name": "canonical_url_id", "datatype": dbt.type_string()},
    {"name": "content_available", "datatype": "boolean"},
    {"name": "content_id", "datatype": dbt.type_numeric()},
    {"name": "device", "datatype": dbt.type_string()},
    {"name": "email_id", "datatype": dbt.type_string()},
    {"name": "email_subject", "datatype": dbt.type_string()},
    {"name": "experiment_id", "datatype": dbt.type_string()},
    {"name": "from_phone_number_id", "datatype": dbt.type_numeric()},
    {"name": "from_smssender_id", "datatype": dbt.type_numeric()},
    {"name": "link_id", "datatype": dbt.type_string()},
    {"name": "link_url", "datatype": dbt.type_string()},
    {"name": "locale", "datatype": dbt.type_string()},
    {"name": "payload", "datatype": dbt.type_string()},
    {"name": "platform_endpoint", "datatype": dbt.type_string()},
    {"name": "push_message", "datatype": dbt.type_string()},
    {"name": "region", "datatype": dbt.type_string()},
    {"name": "sms_message", "datatype": dbt.type_string()},
    {"name": "to_phone_number", "datatype": dbt.type_string()},
    {"name": "url", "datatype": dbt.type_string()},
    {"name": "workflow_id", "datatype": dbt.type_string()},
    {"name": "workflow_name", "datatype": dbt.type_string()},
    {"name": "city", "datatype": dbt.type_string()},
    {"name": "clicked_url", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "error_code", "datatype": dbt.type_string()},
    {"name": "expires_at", "datatype": dbt.type_timestamp()},
    {"name": "from_phone_number", "datatype": dbt.type_string()},
    {"name": "in_app_body", "datatype": dbt.type_string()},
    {"name": "is_sms_estimation", "datatype": "boolean"},
    {"name": "labels", "datatype": dbt.type_string()},
    {"name": "message_status", "datatype": dbt.type_string()},
    {"name": "mms_send_count", "datatype": dbt.type_numeric()},
    {"name": "reason", "datatype": dbt.type_string()},
    {"name": "sms_send_count", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_user_id", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('iterable_event_extension_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}