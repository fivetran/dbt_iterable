#!/bin/bash

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
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{iterable__using_campaign_label_history: false, iterable__using_user_unsubscribed_message_type_history: false, iterable__using_campaign_suppression_list_history: false, iterable__using_user_device_history: true}' --target "$db" --full-refresh
dbt test --target "$db"