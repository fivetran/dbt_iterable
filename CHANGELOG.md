# dbt_iterable v1.1.0
[PR #67](https://github.com/fivetran/dbt_iterable/pull/67) includes the following updates:

## Schema/Data Change
**8 total changes • 0 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| All models | New column | | `source_relation` | Identifies the source connection when using multiple Iterable connections |
| `iterable__campaigns` | Updated surrogate key | `unique_campaign_version_id` = `campaign_id` + `template_id` + `experiment_id` (if enabled) | `unique_campaign_version_id` = `campaign_id` + `template_id` + `source_relation` + `experiment_id` (if enabled) | Updated to include `source_relation` |
| `iterable__user_campaign` | Updated surrogate key | `unique_user_campaign_id` = `unique_user_key` + `campaign_id` + `experiment_id` (if enabled) | `unique_user_campaign_id` = `source_relation` + `unique_user_key` + `campaign_id` + `experiment_id` (if enabled) | Updated to include `source_relation` |
| `int_iterable__list_user_unnest` | Updated surrogate key | `unique_key` = `unique_user_key` + `list_id` + `updated_at` | `unique_key` = `source_relation` + `unique_user_key` + `list_id` + `updated_at` | Updated to include `source_relation` |
| `stg_iterable__event` | Updated surrogate key | `unique_event_id` = `_fivetran_id` + `_fivetran_user_id` | `unique_event_id` = `_fivetran_id` + `_fivetran_user_id` + `source_relation` | Updated to include `source_relation` |
| `stg_iterable__event_extension` | Updated surrogate key | `unique_event_id` = `_fivetran_id` + `_fivetran_user_id` | `unique_event_id` = `_fivetran_id` + `_fivetran_user_id` + `source_relation` | Updated to include `source_relation` |
| `stg_iterable__user_unsubscribed_channel` | Updated surrogate key | `unsub_channel_unique_key` = `_fivetran_id` + `channel_id` + `email` + `updated_at` | `unsub_channel_unique_key` = `_fivetran_id` + `channel_id` + `email` + `updated_at` + `source_relation` | Updated to include `source_relation` |
| `stg_iterable__user_unsub_message_type` | Updated surrogate key | `unsub_message_type_unique_key` = `_fivetran_id` + `email` + `message_type_id` + `updated_at` | `unsub_message_type_unique_key` = `_fivetran_id` + `email` + `message_type_id` + `updated_at` + `source_relation` | Updated to include `source_relation` |

## Feature Update
- **Union Data Functionality**: This release supports running the package on multiple Iterable source connections. See the [README](https://github.com/fivetran/dbt_iterable/tree/main?tab=readme-ov-file#step-3-define-database-and-schema-variables) for details on how to leverage this feature.

## Tests Update
- Removes uniqueness tests. The new unioning feature requires combination-of-column tests to consider the new `source_relation` column in addition to the existing primary key, but this is not supported across dbt versions.
  - These tests will be reintroduced once a version-agnostic solution is available.

# dbt_iterable v1.0.0

[PR #63](https://github.com/fivetran/dbt_iterable/pull/63) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/iterable_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/iterable_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/iterable_source` package will also need to be removed or updated to reference this package.
  - Update any iterable_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_iterable/blob/main/README.md) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Removed all `accepted_values` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_iterable.yml`.

## Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

# dbt_iterable v0.14.0
[PR #59](https://github.com/fivetran/dbt_iterable/pull/59) introduces the following updates:

## Schema Updates
**2 total changes • 2 possible breaking changes for Databricks users**
| Data Model                                                                                                                                               | Change Type | Old                     | New                                             | Notes                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `iterable__events`             | New Databricks file format |  `parquet`  |    `delta`      | Requires `--full-refresh` for Databricks users.    |
| `int_iterable__list_user_unnest`             | New Databricks file format |  `parquet`  |     `delta`     | Requires `--full-refresh` for Databricks users.     |

## Under the Hood
- Updated the package maintainer PR template. 

# dbt_iterable v0.13.1
This release introduces the following updates: 

## Documentation
- Refreshed the docs to account for the upstream update to the macro `does_table_exist`. ([#55](https://github.com/fivetran/dbt_iterable/pull/55))
  - For more information refer to the upstream PR ([#42](https://github.com/fivetran/dbt_iterable_source/pull/42)).
- Added Quickstart model counts to README. ([#54](https://github.com/fivetran/dbt_iterable/pull/54))
- Corrected references to connectors and connections in the README. ([#54](https://github.com/fivetran/dbt_iterable/pull/54))

# dbt_iterable v0.13.0
[PR #51](https://github.com/fivetran/dbt_iterable/pull/51) includes the following updates:

## Breaking Changes (`--full-refresh` required after upgrading)  
- Added a field called `first_open_or_click_event_at` in the `iterable__user_campaign` model. This timestamp shows the first time a user interacted with a campaign, recording the earliest occurring event out of 'emailOpen', 'emailClick', and 'pushOpen'. ([PR #50](https://github.com/fivetran/dbt_iterable/pull/50))
- Corrected the incremental filter in `iterable__events` model to now use the `created_on` date field instead of the `created_at` timestamp. 
   - Previously, this would potentially exclude late-arriving new records from populating in the end models if they had an older `created_at` value than what was present in the model. Switching to `created_on` widens the criteria.
- Updated upstream `stg_iterable__user_history` model from materializing as a table to a view in order to improve performance.
- In order to ensure no issues, a `--full-refresh` is required after upgrading.

## Under the Hood
- In addition to using `created_on` in the incremental logic in `iterable__events`, we introduced a `iterable_lookback_window` variable to increase the window for accommodating potential late-arriving records. The default is 7 days prior to the maximum `created_on` value present in the `iterable__events` model, but you may customize this by setting the var `iterable_lookback_window ` in your dbt_project.yml. See the [Lookback Window section of the README](https://github.com/fivetran/dbt_iterable/blob/main/README.md#lookback-window) for more details.
- Added a section in the [README]((https://github.com/fivetran/dbt_iterable/blob/main/README.md#pivoting-out-event-metrics)) about the `iterable__event_metrics` variable and how to use it to specify which event metrics to pivot out. ([PR #49](https://github.com/fivetran/dbt_iterable/pull/49))
- Removes `created_on` from the uniqueness test in `iterable__events`. Uniqueness is now tested solely on `unique_event_id`, a surrogate key made up of `event_id` (`_fivetran_id` in the raw table, which is a Fivetran-created unique identifier derived from hashing campaign_id, created_at, and event_name) and `_fivetran_user_id` (a Fivetran-created column derived from a hash of `user_id` and/or `email`).
- Modified the `event` seed data to more accurately represent real-life data, with a unique `_fivetran_id` for each `campaign_id`, `created_at`, and `event_name`.
## Documentation Update
- Updates the descriptions of timestamp-based fields. Previously they were described as milliseconds since epoch time, but they should be standard timestamps.

## Contributors
- [@justin-fundrise](https://github.com/justin-fundrise) ([PR #49](https://github.com/fivetran/dbt_iterable/pull/49), [PR #50](https://github.com/fivetran/dbt_iterable/pull/50))

# dbt_iterable v0.12.0
[PR #44](https://github.com/fivetran/dbt_iterable/pull/44) includes the following updates:

## 🚨 Breaking Changes 🚨
- Introduces variable `iterable__using_event_extension` to allow the `event_extension` table to be disabled and exclude its field, `experiment_id`, from persisting downstream. This permits the downstream models to run even if the source `event_extension` table does not exist. By default the variable is set to True. If you don't have this table, you will need to set `iterable__using_event_extension` to False. For more information on how to configure the `iterable__using_event_extension` variable, refer to the [README](https://github.com/fivetran/dbt_iterable/blob/main/README.md#step-4-enablingdisabling-models). 
   - This will be a breaking change if you choose to disable the `event_extension` table as `experiment_id` will be removed from downstream models. Conversely, if you wish to include the `experiment_id` grain, ensure that `iterable__using_event_extension` is not explicitly set to False.
   - Following this, the uniqueness tests in related models have been updated to account for whether `iterable__using_event_extension` is enabled/disabled by now relying on new surrogate keys:
      - `unique_campaign_version_id`: Unique identifier for the `iterable__campaigns` model that combines `campaign_id`, `template_id`, and if available, `experiment_id`.
      - unique_user_campaign_id: Unique identifier for the `iterable__user_campaign` model that combines `unique_user_key`, `campaign_id`, and if available, `experiment_id`.

- Persists `user_history` passthrough columns, as stipulated via the `iterable_user_history_pass_through_columns` variable, through to the `iterable__users` model. For more information on how to configure the `iterable_user_history_pass_through_columns` variable, refer to the [README](https://github.com/fivetran/dbt_iterable/blob/main/README.md#passing-through-additional-fields).

## Under the Hood
- Updates logic in `int_iterable__campaign_event_metrics`, `iterable__events`, and `iterable__user_campaign` to account for the `iterable__using_event_extension` variable being disabled or enabled. If disabled, `experiment_id` will not show up as a grain.
- Addition of integrity and consistency validation tests within integration tests pertaining to the `iterable__user_unsubscriptions`, `iterable__campaigns`, `iterable__events`, `iterable__user_campaign`, and `iterable_users` models.
- Updated seed data to ensure proper testing of the latest [v0.8.1 `dbt_iterable_source` release](https://github.com/fivetran/dbt_iterable_source/releases/tag/v0.8.1) in addition to testing of the pass_through column features.
- Updated [pull request and issue templates](https://github.com/fivetran/dbt_iterable_source/tree/v0.8.1/.github).
- Included auto-releaser GitHub Actions workflow to automate future releases.


# dbt_iterable v0.11.0
[PR #39](https://github.com/fivetran/dbt_iterable/pull/39) includes updates in response to the [Aug 2023 updates](https://fivetran.com/docs/applications/iterable/changelog#august2023) for the Iterable connector.

For changes in the upstream staging models, refer to the dbt_iterable_source [changelog](https://github.com/fivetran/dbt_iterable_source/compare/v0.7.0...v0.8.0) and respective [PR #28](https://github.com/fivetran/dbt_iterable_source/pull/28).

## 🚨 Breaking Changes 🚨
- Introduced a new user key `unique_user_key`. If you are syncing the new schema from Iterable, this will be `_fivetran_user_id`, generated from hashing `user_id` and/or `email`, depending on project type. Otherwise, this is `email`, the user identifier for email-based projects and was the previous unique user key used in the old schema. 
  - Models that have previously used `email` as a grain or as a join field have been updated to use `unique_user_key`.
- The grain in `iterable__events` was previously on `event_id` but is now `unique_event_id`. This is a generated surrogate key from `event_id` and `_fivetran_user_id`. Due to the Iterable Aug 2023 updates, previously the unique key for events was just `event_id`, but now the unique keys involves a combination of `event_id` and `_fivetran_user_id`, if it exists.
- We have removed `user_device` related fields as we removed the underlying object.

## 🎉 Feature Update 🎉
- Added the passthrough columns functionality for `event_extension` and `user_history` source tables. You will see these additional columns persist through the end `iterable__events` and `iterable__users` models. For instructions on leveraging this feature, refer to the [README](./README.md#passing-through-additional-fields).
  - **Notice**: A `dbt run --full-refresh` is required each time these variables are edited.

## Test Updates
- Updated the tests for uniqueness that were using `email` to `unique_user_key`.
- The unique test in `iterable__events` now tests on `unique_event_id` instead of `event_id`.
- The unique test in `iterable__user_unsubscriptions` now tests on `unique_user_key, message_type_id, channel_id,` and `is_unsubscribed_channel_wide`.

# dbt_iterable v0.10.0
[PR #34](https://github.com/fivetran/dbt_iterable/pull/34) includes the following updates:

## 🚨 Breaking Changes 🚨
- Added additional join on `template_id` in `iterable__campaigns` so the proper grain is being reflected.
- Updated `dbt_utils.unique_combination_of_columns` test on `iterable__campaigns` to include `template_id`.

## 🪲 Bug Fix ⚒️
- Adjusted intermediate model logic in `int_iterable__campaign_event_metrics` to correctly count unique totals based off of distinct email values for `iterable__campaigns`.
- Added additional join on `template_id` in `int_iterable__recurring_campaigns` to resolve a data fanout issue

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
