# dbt_iterable v0.10.0
[PR #34](https://github.com/fivetran/dbt_iterable/pull/34) includes the following updates:

## 🚨 Breaking Changes 🚨
- Updated grain of `iterable_campaigns` to include `template_id` to fix potential fan-out issues. 
- Updated `dbt_utils.unique_combination_of_columns` test on `iterable__campaigns` to include `template_id`.

## 🪲 Bug Fix ⚒️
- Adjusted intermediate model logic to correctly count unique totals based off of distinct email values for `iterable__campaigns`.

# dbt_iterable v0.9.0
[PR #33](https://github.com/fivetran/dbt_iterable/pull/33) includes the following update:
## 🚨 Breaking Changes 🚨 (recommend `--full-refresh` for Bigquery and Snowflake users)
- Updated intermediate model `int_iterable__list_user_unnest` to make sure empty array-rows are not removed for all warehouses.
- **Bigquery and Snowflake users**: this affects downstream models `iterable__users` and `iterable__list_user_history`. We recommend using `dbt run --full-refresh` the next time you run your project.

# dbt_iterable v0.8.0
[PR #30](https://github.com/fivetran/dbt_iterable/pull/30) includes the following updates:
## 🚨 Breaking Changes 🚨 (recommend `--full-refresh`)
- Updated the incremental strategy for end model `iterable__events`:
  - For Bigquery, Spark, and Databricks, the strategy has been updated to `insert_overwrite`. 
  - For Snowflake, Redshift, and PostgreSQL, the strategy has been updated to `delete+insert`.
  - We recommend running `dbt run --full-refresh` the next time you run your project.
## 🎉 Feature Update 🎉
- Databricks compatibility for Runtime 12.2 or later. 
  - Note some models may run with an earlier runtime, however 12.2 or later is required to run all models. This is because of syntax changes from earlier versions for use with arrays and JSON.
- We also recommend using the `dbt-databricks` adapter over `dbt-spark` because each adapter handles incremental models differently. If you must use the `dbt-spark` adapter and run into issues, please refer to [this section](https://docs.getdbt.com/reference/resource-configs/spark-configs#the-insert_overwrite-strategy) found in dbt's documentation of Spark configurations.

[PR #27](https://github.com/fivetran/dbt_iterable/pull/27) includes the following updates:
## 🚘 Under the Hood 🚘
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. 
- Updated the pull request [templates](/.github).


# dbt_iterable v0.7.0
[PR #28](https://github.com/fivetran/dbt_iterable/pull/28) adds the following changes:

## 🚨 Breaking Changes 🚨
- Adjusts the default materialization of `int_iterable__list_user_history` from a view to a table. This was changed to optimize the runtime of the downstream `int_iterable__list_user_unnest` model.
- Updates `int_iterable__list_user_unnest` to be materialized as an incremental table. In order to add this logic, we also added a new `unique_key` field -- a surrogate key hashed on `email`, `list_id`, and `updated_at` -- and a `date_day` field to partition by on Bigquery + Databricks.
  - **You will need to run a full refresh first to pick up the new columns**.

## Under the Hood
- Adds a `coalesce` to `previous_email_ids` in the `int_iterable__list_user_history` model, in case there are no previous email ids.
- Adjusts the `flatten` logic in `int_iterable__list_user_unnest` for Snowflake users.


# dbt_iterable v0.6.0

## 🚨 Breaking Changes 🚨
- Added `iterable_[source_table_name]_identifier` variables to the source package to allow easier flexibility of the package to refer to source tables with different names. 
- **Note!** For the table `campaign_suppression_list_history`, the identifier variable has been updated from `iterable__campaign_suppression_list_history_table` to `iterable_campaign_suppression_list_history_identifier` to align with the current naming convention. If you are using the former variable in your `dbt_project.yml`, you will need to update it for the package to run. ([#25](https://github.com/fivetran/dbt_iterable/pull/25))

## 🎉 Features
- Updated README with identifier instructions and format update. ([#25](https://github.com/fivetran/dbt_iterable/pull/25))

# dbt_iterable v0.5.0

## 🚨 Breaking Changes 🚨:
[PR #18](https://github.com/fivetran/dbt_iterable/pull/18) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.
- Incremental strategy within `iterable__events` has been modified to use delete+insert for Redshift and Postgres warehouses.
# dbt_iterable v0.4.1
## 🎉 Documentation and Feature Updates
- Introduced variable `iterable__using_campaign_suppression_list_history` to disable related downtream portions if the underlying source table does not existed. For how to configure refer to the [README](https://github.com/fivetran/dbt_iterable/blob/main/README.md#enabling-and-disabling-models). 
- Specifically, we have added conditional blocks to relevant portions of `int_iterable__campaign_lists` if the  underlying `stg_iterable__campaign_suppression_list_history` is not materialized when `iterable__using_campaign_suppression_list_history` is disabled. ([#22](https://github.com/fivetran/dbt_iterable/pull/22))
## Contributors
Thank you @awpharr for raising these to our attention! ([#19](https://github.com/fivetran/dbt_iterable/issues/19))

# dbt_iterable v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_iterable_source`. Additionally, the latest `dbt_iterable_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_iterable v0.1.0 -> v0.3.1
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
