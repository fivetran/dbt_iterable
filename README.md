<!--section="iterable_transformation_model"-->
# Iterable dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_iterable/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/data-models/quickstart-management#quickstartmanagement">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Iterable connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 45
- Connector documentation
  - [Iterable connector documentation](https://fivetran.com/docs/connectors/applications/iterable)
  - [Iterable ERD](https://fivetran.com/docs/connectors/applications/iterable#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_iterable)
  - [dbt Docs](https://fivetran.github.io/dbt_iterable/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_iterable/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_iterable/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to understand the efficacy of your growth marketing and customer engagement campaigns across email, SMS, push notification, and in-app platforms. It creates enriched models with metrics focused on event interactions, campaign performance, and user engagement.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_iterable
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [iterable__events](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__events) | Tracks all user events with campaign attribution, user details, and channel information to analyze user behavior, conversion paths, and campaign effectiveness at the event level. See [tracked events details](https://fivetran.com/docs/applications/iterable#schemanotes). <br></br>**Example Analytics Questions:**<ul><li>What customer actions drive the most revenue and conversions?</li><li>Are our marketing campaigns more effective than organic customer discovery?</li><li>What customer journey paths lead to purchase or upgrade?</li></ul>|
| [iterable__user_campaign](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__user_campaign) | Aggregates user-level engagement with specific campaigns and experiment variations including event counts by type to measure individual user responses to campaign messaging. <br></br>**Example Analytics Questions:**<ul><li>Which customers are most responsive to our campaigns, and what messages resonate with them?</li><li>Which email variations are winning with our audience?</li><li>How frequently do customers engage with each campaign?</li></ul>|
| [iterable__campaigns](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__campaigns) | Tracks campaign performance with user interaction metrics, event counts, experiment variations, and template details to measure campaign effectiveness and optimize email strategy. <br></br>**Example Analytics Questions:**<ul><li>Which campaigns are driving the most engagement and sales?</li><li>How do different email designs and messaging strategies perform?</li><li>What's the reach and impact of our marketing initiatives?</li></ul>|
| [iterable__users](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__users) | Provides a comprehensive view of each user with campaign engagement history, list memberships, unsubscription status, and interaction metrics to understand user preferences and lifetime engagement. <br></br>**Example Analytics Questions:**<ul><li>Who are our most engaged customers and what do they have in common?</li><li>Why are customers unsubscribing, and what did we lose when they left?</li><li>Which acquisition channels bring us the most engaged customers?</li></ul>|
| [iterable__list_user_history](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__list_user_history) | Chronicles user-list membership history to track when users join or leave lists, manage audience segmentation, and analyze list growth without excessive Monthly Active Rows (MAR) usage. <br></br>**Example Analytics Questions:**<ul><li>Are we growing or losing our subscriber base in key segments?</li><li>Which customers are moving between audience segments, and why?</li><li>How long do customers stay engaged before opting out?</li></ul>|
| [iterable__user_unsubscriptions](https://fivetran.github.io/dbt_iterable/#!/model/model.iterable.iterable__user_unsubscriptions) | Tracks all user unsubscriptions by message type and channel to manage communication preferences, protect sender reputation, and identify unsubscribe patterns. <br></br>**Example Analytics Questions:**<ul><li>Which types of messages are causing customers to opt out?</li><li>Are we losing customers completely, or just from certain communication types?</li><li>What patterns indicate a customer is likely to unsubscribe?</li></ul>|

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Iterable connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Unsubscribe tables are no longer history tables

For connections created past August 2023, the `user_unsubscribed_channel_history` and `user_unsubscribed_message_type_history` Iterable objects will no longer be history tables as part of schema changes following Iterable's API updates. The fields have also changed. There is no lift required, since we have checks in place that will automatically persist the respective fields depending on what exists in your schema (they will still be history tables if you are using the old schema).

*Please be sure you are syncing them as either both history or non-history.*

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_iterable/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following Iterable package version in your `packages.yml` file.

> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/iterable
    version: [">=1.4.0", "<1.5.0"]
```

#### Database Incremental Strategies
Many of the models in this package are materialized incrementally, so we have configured our models to work with the different strategies available to each supported warehouse.

For **BigQuery** and **Databricks All Purpose Cluster runtime** destinations, we have chosen `insert_overwrite` as the default strategy, which benefits from the partitioning capability.

For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen `delete+insert` as the default strategy.

> Regardless of strategy, we recommend that users periodically run a `--full-refresh` to ensure a high level of data quality.

#### Databricks Configuration
- **Databricks Runtime 12.2** or later is required to run all models in this package.
- We also recommend using the `dbt-databricks` adapter over `dbt-spark` because each adapter handles incremental models differently. If you must use the `dbt-spark` adapter and run into issues, please refer to [this section](https://docs.getdbt.com/reference/resource-configs/spark-configs#the-insert_overwrite-strategy) found in dbt's documentation of Spark configurations.

### Define database and schema variables

#### Option A: Single connection
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `iterable` schema. If this is not where your Iterable data is (for example, if your Iterable schema is named `iterable_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  iterable:
    iterable_database: your_database_name
    iterable_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Iterable connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `iterable_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  iterable:
    iterable_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Iterable connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Iterable source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `iterable`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Iterable sources, though the package will run successfully.

To properly incorporate all of your Iterable connections into your project's DAG:
1. Define each of your sources in a `.yml` file in your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_iterable.yml` [file](https://github.com/fivetran/dbt_iterable/blob/main/models/staging/src_iterable.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in iterable_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from iterable/models/staging/src_iterable.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Enabling/Disabling Models](https://github.com/fivetran/dbt_iterable?tab=readme-ov-file#enablingdisabling-models)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `iterable` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  iterable:
    has_defined_sources: true
```
### Enabling/Disabling Models
Your Iterable connection might not sync every table that this package expects. If your syncs exclude certain tables, it is either because you do not use that functionality in Iterable or have actively excluded some tables from your syncs. In order to enable or disable the relevant tables in the package, you will need to add the following variable(s) to your `dbt_project.yml` file.

By default, all variables are assumed to be `true`.

```yml
vars:
    iterable__using_campaign_label_history: false                    # default is true
    iterable__using_user_unsubscribed_message_type_history: false    # default is true
    iterable__using_campaign_suppression_list_history: false         # default is true   
    iterable__using_event_extension: false         # default is true   
```

### (Optional) Additional configurations

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
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

> Note: If your profile does not have permissions to create schemas in your destination, you can set each `+schema` to blank. The package will then write all tables to your pre-existing target schema.

#### Change the source table references
If an individual source table has a different name than what the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_iterable/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    iterable_<default_source_table_name>_identifier: "your_table_name"
```

#### Pivoting out event metrics 
In the `iterable__user_campaign` model, there are metrics calculated based on Iterable events. By default, all the below metrics are enabled by default. If not all metrics apply to your use case, you can specify which event metrics to include by adjusting the `iterable__event_metrics` variable in your own `dbt_project.yml`.

```yml
vars:
    iterable__event_metrics:
    - "emailClick"
    - "emailUnSubscribe"
    - "emailComplaint"
    - "customEvent"
    - "emailSubscribe"
    - "emailOpen"
    - "pushSend"
    - "smsBounce"
    - "pushBounce"
    - "inAppSendSkip"
    - "smsSend"
    - "inAppSend"
    - "pushOpen"
    - "emailSend"
    - "pushSendSkip"
    - "inAppOpen"
    - "emailSendSkip"
    - "emailBounce"
    - "inAppClick"
    - "pushUninstall"
```

#### Lookback Window
Records from the source can sometimes arrive late. Since several of the models in this package are incremental, by default we look back 7 days to ensure late arrivals are captured while avoiding the need for frequent full refreshes. While the frequency can be reduced, we still recommend running `dbt --full-refresh` periodically to maintain data quality of the models.

To change the default lookback window, add the following variable to your `dbt_project.yml` file:

```yml
vars:
  iterable:
    iterable_lookback_window: number_of_days # default is 7
```

#### Deprecated `CAMPAIGN_SUPRESSION_LIST_HISTORY` table

The Iterable connector schema originally misspelled the `CAMPAIGN_SUPPRESSION_LIST_HISTORY` table as `CAMPAIGN_SUPRESSION_LIST_HISTORY` (note the singular `P`). As of August 2021, Fivetran has deprecated the misspelled table and will only continue syncing the correctly named `CAMPAIGN_SUPPRESSION_LIST_HISTORY` table.

By default, this package refers to the new table (`CAMPAIGN_SUPPRESSION_LIST_HISTORY`). To change this so that the package works with the old misspelled source table (we do not recommend this, however), add the following configuration to your `dbt_project.yml` file:

```yml
vars:
    iterable_campaign_suppression_list_history_identifier: "campaign_supression_list_history"
```

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

```

<!--section="iterable_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/iterable/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_iterable/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_iterable/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).