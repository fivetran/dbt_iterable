
with base as (

    select * 
    from {{ ref('stg_iterable__template_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_iterable__template_history_tmp')),
                staging_columns=get_template_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(id as {{ dbt.type_string() }} ) as template_id,
        name as template_name,
        template_type,
        created_at,
        cast(client_template_id as {{ dbt.type_string() }} ) as client_template_id,
        cast(creator_user_id as {{ dbt.type_string() }} ) as creator_user_id,
        cast(message_type_id as {{ dbt.type_string() }} ) as message_type_id,
        updated_at,
        _fivetran_synced
    from fields
)

select * 
from final
