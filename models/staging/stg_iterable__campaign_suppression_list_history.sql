{{ config(enabled=var('iterable__using_campaign_suppression_list_history', True)) }}

with base as (

    select * 
    from {{ ref('stg_iterable__campaign_suppression_list_history_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_iterable__campaign_suppression_list_history_tmp')),
                staging_columns=get_campaign_suppression_list_history_columns()
            )
        }}
        {{ iterable.apply_source_relation() }}

    from base
),

final as (

    select
        source_relation,
        cast(campaign_id as {{ dbt.type_string() }}) as campaign_id,
        cast(suppressed_list_id as {{ dbt.type_string() }}) as suppressed_list_id,
        updated_at,
        _fivetran_synced
    from fields
)

select * 
from final
