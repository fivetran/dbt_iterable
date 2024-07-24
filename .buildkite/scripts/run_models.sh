#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt compile --target "$db"
dbt run --target "$db" --full-refresh
dbt run --target "$db"
dbt test --target "$db"
dbt run --vars '{iterable_user_history_pass_through_columns: [{name: "phone_number_updated_at"}], iterable_event_extension_pass_through_columns: [{name: "web_push_message"}]}' --target "$db" --full-refresh
dbt run --vars '{iterable__using_campaign_label_history: false, iterable__using_user_unsubscribed_message_type_history: false, iterable__using_campaign_suppression_list_history: false, iterable__using_event_extension: false}' --target "$db" —-full-refresh
dbt run --vars '{iterable__using_campaign_label_history: false, iterable__using_user_unsubscribed_message_type_history: false, iterable__using_campaign_suppression_list_history: false, iterable__using_event_extension: false}' --target "$db"
dbt run --vars '{does_table_exist('user_unsubscribed_message_type'): false, does_table_exist('user_unsubscribed_channel'): false}' --target "$db" --full-refresh
dbt test --target "$db"
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"