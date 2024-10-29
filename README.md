<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_iterable/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# Iterable Transformation dbt Package ([docs](https://fivetran.github.io/dbt_iterable/))
## What does this dbt package do?
- Produces modeled tables that leverage Iterable data from [Fivetran's connector](https://fivetran.com/docs/applications/iterable) in the format described by [this ERD](https://fivetran.com/docs/applications/iterable#schemainformation) and builds off the output of our [Iterable source package](https://github.com/fivetran/dbt_iterable_source).

- This package enables you to understand the efficacy of your growth marketing and customer engagement campaigns across email, SMS, push notification, and in-app platforms. The package achieves this by:

  - Enriching the core `EVENT` table with data regarding associated users, campaigns, and channels.
  - Creating current-state models of campaigns and users, enriched with aggregated event and interaction metrics.
  - Creating a current-state model of message types and channels that each user is currently unsubscribed from.
  - Re-creating the `LIST_USER_HISTORY` table. The table can be disabled from connector syncs but is required to connect users and their lists.

- Generates a comprehensive data dictionary of your source and modeled Iterable data through the [dbt docs site](https://fivetran.github.io/dbt_iterable/).

<!--section="iterable_transformation_model-->
The following table provides a detailed list of all tables materialized within this package by default.

> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_iterable/).

| **Table**                | **Description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [iterable__events](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__events)             | Each record represents a unique event in Iterable, enhanced with information regarding attributed campaigns, the triggering user, and the channel, template, and message type associated with the event. Commerce events are not tracked by the Fivetran connector. See the [tracked events details](https://fivetran.com/docs/applications/iterable#schemanotes). |
| [iterable__user_campaign](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__user_campaign)             | Each record represents a unique user-campaign-experiment variation combination, enriched with pivoted-out metrics reflecting instances of the user triggering different types of events in campaigns.
| [iterable__campaigns](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__campaigns)             | Each record represents a unique campaign-experiment variation, enriched with gross event and unique user interaction metrics, and information regarding templates, labels, and applied or suppressed lists. |
| [iterable__users](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__users)             | Each record represents the most current state of a unique user, enriched with metrics around the campaigns and lists they have been a part of and interacted with, channels and message types they've unsubscribed from, and more. |
| [iterable__list_user_history](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__list_user_history)             | Each record represents a unique user-list combination. This is intended to recreate the `LIST_USER_HISTORY` source table, which can be disconnected from your syncs, as it can lead to excessive MAR usage. |
| [iterable__user_unsubscriptions](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__user_unsubscriptions)             | Each row represents a message type that a user is currently unsubscribed to, including the channel the message type belongs to. If a user is unsubscribed from an entire channel, each of the channel's message types appears as an unsubscription. |

<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Iterable connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Databricks Configuration
- **Databricks Runtime 12.2** or later is required to run all models in this package.
- We also recommend using the `dbt-databricks` adapter over `dbt-spark` because each adapter handles incremental models differently. If you must use the `dbt-spark` adapter and run into issues, please refer to [this section](https://docs.getdbt.com/reference/resource-configs/spark-configs#the-insert_overwrite-strategy) found in dbt's documentation of Spark configurations.

#### Database Incremental Strategies
Some of the end models in this package are materialized incrementally. We have chosen `insert_overwrite` as the default strategy for **BigQuery** and **Databricks** databases, as it is only available for these dbt adapters. For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen `delete+insert` as the default strategy.

`insert_overwrite` is our preferred incremental strategy because it will be able to properly handle updates to records that exist outside the immediate incremental window. That is, because it leverages partitions, `insert_overwrite` will appropriately update existing rows that have been changed upstream instead of inserting duplicates of them--all without requiring a full table scan.

`delete+insert` is our second-choice as it resembles `insert_overwrite` but lacks partitions. This strategy works most of the time and appropriately handles incremental loads that do not contain changes to past records. However, if a past record has been updated and is outside of the incremental window, `delete+insert` will insert a duplicate record.
> Because of this, we highly recommend that **Snowflake**, **Redshift**, and **Postgres** users periodically run a `--full-refresh` to ensure a high level of data quality and remove any possible duplicates.

#### Unsubscribe tables are no longer history tables

For connectors created past August 2023, the `user_unsubscribed_channel_history` and `user_unsubscribed_message_type_history` Iterable objects will no longer be history tables as part of schema changes following Iterable's API updates. The fields have also changed. There is no lift required, since we have checks in place that will automatically persist the respective fields depending on what exists in your schema (they will still be history tables if you are using the old schema).

*Please be sure you are syncing them as either both history or non-history.*

### Step 2: Install the package
Include the following Iterable package version in your `packages.yml` file.

> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/iterable
    version: [">=0.13.0", "<0.14.0"]
```
### Step 3: Define database and schema variables
By default, this package runs using your destination and the `iterable` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Iterable data is located (for example, if your Iterable schema is named `iterable_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  iterable_database: your_database_name
  iterable_schema: your_schema_name 
```
### Step 4: Enabling/Disabling Models
Your Iterable connector might not sync every table that this package expects. If your syncs exclude certain tables, it is either because you do not use that functionality in Iterable or have actively excluded some tables from your syncs. In order to enable or disable the relevant tables in the package, you will need to add the following variable(s) to your `dbt_project.yml` file.

By default, all variables are assumed to be `true`.


```yml
vars:
    iterable__using_campaign_label_history: false                    # default is true
    iterable__using_user_unsubscribed_message_type_history: false    # default is true
    iterable__using_campaign_suppression_list_history: false         # default is true   
    iterable__using_event_extension: false         # default is true   
```



### (Optional) Step 5: Additional configurations

#### Passing Through Additional Fields

This package includes fields we judged were standard across Iterable users. However, the Fivetran connector allows for additional columns to be brought through in the `event_extension` and `user_history` objects. Therefore, if you wish to bring them through, leverage our passthrough column variables. For `event_extension` columns, ensure that `iterable__using_event_extension` is set to True, which is the default.

You will see these additional columns populate in the end `iterable__list_user_history`, `iterable__events`, and `iterable__users` models.

**Notice**: A `dbt run --full-refresh` is required each time these variables are edited.

These variables allow for the passthrough fields to be aliased (alias) and casted (transform_sql) if desired, but not required. Datatype casting is configured via a sql snippet within the transform_sql key. You may add the desired sql while omitting the as field_name at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:

```yml
# dbt_project.yml

vars:
  iterable_event_extension_pass_through_columns:
    - name: "event_extension_field"
      alias: "renamed_field"
      transform_sql: "cast(renamed_field as string)"
  iterable_user_history_pass_through_columns:
    - name: "user_attribute"
      alias: "renamed_user_attribute"
    - name: "user_attribute_2"
```

#### Changing the Build Schema

By default, this package will build the following Iterable models within the schemas below in your target database:

- Final models within a schema titled (`<target_schema>` + `_iterable`)
- Intermediate models in (`<target_schema>` + `_int_iterable`)
- Staging models within a schema titled (`<target_schema>` + `_stg_iterable`)

If this is not where you would like your modeled Iterable data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
  iterable:
    +schema: my_new_schema_name # leave blank for just the target_schema
    intermediate:
      +schema: my_new_schema_name # leave blank for just the target_schema
  iterable_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

> Note: If your profile does not have permissions to create schemas in your destination, you can set each `+schema` to blank. The package will then write all tables to your pre-existing target schema.

#### Change the source table references
If an individual source table has a different name than what the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_iterable_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    iterable_<default_source_table_name>_identifier: "your_table_name"
```

#### Pivoting out event metrics 
In the `iterable__user_campaign` model, there are metrics calculated based on Iterable events. By default, all event metrics are enabled as shown in the [`dbt_project.yml`](https://github.com/fivetran/dbt_iterable/blob/2c0c1764f55af255726397a374b48004de20cf51/dbt_project.yml#L34). If not all metrics apply to your use case, you can specify which event metrics to include by configuring the variable `iterable__event_metrics` in your own `dbt_project.yml` as shown below.  

```yml
vars:
  iterable__event_metrics:
    - "emailSend"
    - "emailOpen"
```

#### Lookback Window
Records from the source can sometimes arrive late. Since several of the models in this package are incremental, by default we look back 7 days to ensure late arrivals are captured while avoiding the need for frequent full refreshes. While the frequency can be reduced, we still recommend running `dbt --full-refresh` periodically to maintain data quality of the models.

To change the default lookback window, add the following variable to your `dbt_project.yml` file:

```yml
vars:
  iterable:
    lookback_window: number_of_days # default is 7
```

#### Deprecated `CAMPAIGN_SUPRESSION_LIST_HISTORY` table

The Iterable connector schema originally misspelled the `CAMPAIGN_SUPPRESSION_LIST_HISTORY` table as `CAMPAIGN_SUPRESSION_LIST_HISTORY` (note the singular `P`). As of August 2021, Fivetran has deprecated the misspelled table and will only continue syncing the correctly named `CAMPAIGN_SUPPRESSION_LIST_HISTORY` table.

By default, this package refers to the new table (`CAMPAIGN_SUPPRESSION_LIST_HISTORY`). To change this so that the package works with the old misspelled source table (we do not recommend this, however), add the following configuration to your `dbt_project.yml` file:

```yml
vars:
    iterable_campaign_suppression_list_history_identifier: "campaign_supression_list_history"
```

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: fivetran/iterable_source
      version: [">=0.10.0", "<0.11.0"]
```

## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/iterable/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_iterable/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_iterable/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
