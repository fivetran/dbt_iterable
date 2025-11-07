
with base as (

    select * 
    from {{ ref('stg_iterable__message_type_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_iterable__message_type_tmp')),
                staging_columns=get_message_type_columns()
            )
        }}
        {{ iterable.apply_source_relation() }}

    from base
),

final as (

    select
        source_relation,
        cast(id as {{ dbt.type_string() }} ) as message_type_id,
        name as message_type_name,
        cast(channel_id as {{ dbt.type_string() }} ) as channel_id,
        created_at as message_type_created_at,
        frequency_cap,
        rate_limit_per_minute,
        subscription_policy,
        updated_at as message_type_updated_at,
        _fivetran_synced
    from fields
    where not coalesce(_fivetran_deleted, true)
)

select * 
from final
