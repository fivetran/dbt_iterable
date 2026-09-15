{{ config(enabled=var('iterable__using_journey', True)) }}

{% set source_columns_in_relation = adapter.get_columns_in_relation(ref('stg_iterable__journey_tmp')) %}

with base as (

    select *
    from {{ ref('stg_iterable__journey_tmp') }}

),

fields as (

    select

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=source_columns_in_relation,
                staging_columns=get_journey_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='iterable') }}

    from base
),

final as (

    select
        source_relation,
        cast(id as {{ dbt.type_string() }} ) as journey_id,
        name as journey_name,
        journey_type,
        description as journey_description,
        cast(creator_user_id as {{ dbt.type_string() }} ) as creator_user_id,
        enabled as is_enabled,
        is_archived,
        lifetime_limit,
        simultaneous_limit,
        cast(start_tile_id as {{ dbt.type_string() }} ) as start_tile_id,
        {{ iterable.json_to_string("trigger_event_names", source_columns_in_relation) }} as trigger_event_names,
        created_at,
        updated_at,
        _fivetran_synced

        --The below script allows for pass through columns.
        {{ fivetran_utils.fill_pass_through_columns('iterable_journey_pass_through_columns') }}

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
