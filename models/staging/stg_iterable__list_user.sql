{{ config(materialized='view') }}
{% set source_columns_in_relation = adapter.get_columns_in_relation(ref('stg_iterable__list_user_tmp')) %}


with base as (

    select *
    from {{ ref('stg_iterable__list_user_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns
        that are expected/needed (staging_columns from dbt_iterable/models/tmp/) and compares it with columns
        in the source (source_columns from dbt_iterable/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
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
        list_user_index,
        list_id,
        _fivetran_synced

    from fields
)

select *
from final