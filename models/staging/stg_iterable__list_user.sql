{% set source_columns_in_relation = adapter.get_columns_in_relation(ref('stg_iterable__list_user_tmp')) %}

with base as (

    select *
    from {{ ref('stg_iterable__list_user_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=source_columns_in_relation,
                staging_columns=get_list_user_columns()
            )
        }}
        {{ iterable.apply_source_relation() }}

    from base
),

final as (

    select
        source_relation,
        cast(_fivetran_id as {{ dbt.type_string() }} ) as _fivetran_user_id,
        index as list_user_index,
        list_id,
        _fivetran_synced

    from fields
)

select *
from final