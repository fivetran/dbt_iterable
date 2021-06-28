# Iterable

This package models Iterable data from [Fivetran's connector](https://fivetran.com/docs/applications/iterable). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/iterable#schemainformation).

This package enables you to understand the efficacy of your growth marketing and customer engagement campaigns across email, SMS, push notification, and in-app platforms. The package achieves this by:

- Enriching the core `EVENT` table with data regarding associated users, campaigns, and channels.
- Creating current-state models of campaigns and users, enriched with aggregated event and interaction metrics.
- Re-creating the `LIST_USER_HISTORY` table. The table can be disabled from connector syncs but is required to connect users and lists they belong to.

## Models

This package contains transformation models, designed to work simultaneously with our [Iterable source package](https://github.com/fivetran/dbt_iterable_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [iterable__events](models/iterable__events.sql)             | Each record represents a unique event in Iterable, enhanced with information regarding attributed campaigns, the triggering user, and the channel and message type associated with the event. Commerce events are not tracked by the Fivetran connector. See the [tracked events details](https://fivetran.com/docs/applications/iterable#schemanotes). |
| [iterable__user_campaign](models/iterable__user_campaign.sql)             | Each record represents a unique user-campaign combination, enriched with pivoted-out metrics reflecting instances of the user triggering different types of events in campaigns.
| [iterable__campaigns](models/iterable__campaigns.sql)             | Each record represents a unique campaign, enriched with gross event and unique user interaction metrics, and information regarding templates, labels, and applied or suppressed lists. |
| [iterable__users](models/iterable__users.sql)             | Each record represents the most current state of a unique user, enriched with metrics around the campaigns and lists they have been a part of and interacted with, channels and message types they've unsubscribed from, their associated devices, and more. |
| [iterable__list_user_history](models/iterable__list_user_history.sql)             | Each record represents a unique user-list combination. This is intended to recreate the `LIST_USER_HISTORY` source table, which can be disconnected from your syncs, as it can perhaps create excessive MAR. |

## Installation Instructions

Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yml
# packages.yml
packages:
  - package: fivetran/iterable
    version: [">=0.1.0", "<0.2.0"]
```

## Configuration

By default, this package looks for your Iterable data in the `iterable` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Iterable data is, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
  iterable_database: your_database_name
  iterable_schema: your_schema_name 
```

### Enabling and Disabling Models

When setting up your Iterable connection in Fivetran, it is possible that not every table this package expects will be synced. This can occur because you either don't use that functionality in Iterable or have actively decided to not sync some tables. In order to enable or disable the relevant functionality in the package, you will need to add the relevant variables.

By default, all variables are assumed to be `true` (with exception of `iterable__using_user_device_history`, which is set to `false`). You only need to add variables for the tables you would like to disable or enable respectively:

```yml
# dbt_project.yml

config-version: 2

vars:
    iterable__using_campaign_label_history: false                    # default is true
    iterable__using_user_unsubscribed_message_type_history: false    # default is true

    iterable__using_user_device_history: true                        # default is FALSE
```

### Deprecating `CAMPAIGN_SUPRESSION_LIST_HISTORY` table

Originally, the connector schema misspelled the `CAMPAIGN_SUPPRESSION_LIST_HISTORY` table as `CAMPAIGN_SUPRESSION_LIST_HISTORY` (note the singular `P`). As of June 2021, the misspelled table will be phased out and replaced with a table with the correct spelling.

Connectors set up after June 2021 will have the _new correct spelling_, and pre-existing connectors will contain both for a limited time, after which Fivetran will no longer support syncing the old table, `CAMPAIGN_SUPRESSION_LIST_HISTORY`.

Thus, by default, this package refers to the _new spelling_ (`CAMPAIGN_SUPPRESSION_LIST_HISTORY`). To change this so that the package works with the old misspelled source table, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

config-version: 2

vars:
    iterable_source:
        campaign_suppression_list_history: "{{ source('iterable', 'campaign_supression_list_history') }}" 
        using_old_spelling: true # default false
```

### Changing the Build Schema

By default, this package will build the following Iterable models within the schemas below in your target database:

- Final models within a schema titled (`<target_schema>` + `_iterable`) 
- Intermediate models in (`<target_schema>` + `_int_iterable`) 
- Staging models within a schema titled (`<target_schema>` + `_stg_iterable`) 
 
If this is not where you would like your modeled Iterable data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
  iterable:
    +schema: my_new_schema_name # leave blank for just the target_schema
    intermediate:
      +schema: my_new_schema_name # leave blank for just the target_schema
  iterable_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

> Note: If your profile does not have permissions to create schemas in your destination, you can set each `+schema` to blank. The package will then write all tables to your pre-existing target schema.

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `main`. See the 
[Discourse post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Database Support

This package has been tested on BigQuery, Snowflake, Redshift, and Postgres.

## Resources:

- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Have questions, feedback, or need help? Book a time during our office hours [using Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn how to orchestrate [dbt transformations with Fivetran](https://fivetran.com/docs/transformations/dbt)
- Learn more about Fivetran overall [in our docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
