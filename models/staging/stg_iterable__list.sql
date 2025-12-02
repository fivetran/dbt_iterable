
with base as (

    select * 
    from {{ ref('stg_iterable__list_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_iterable__list_tmp')),
                staging_columns=get_list_columns()
            )
        }}
        {{ iterable.apply_source_relation() }}
        
    from base
),

final as (

    select
        source_relation,
        id as list_id,
        name as list_name,
        list_type,
        created_at,
        description as list_description,
        _fivetran_synced
    from fields
    where not coalesce(_fivetran_deleted, true)
)

select * 
from final
