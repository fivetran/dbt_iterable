{{ config(
    enabled=target.type not in ('spark', 'databricks')
) }}

select *
from {{ ref('iterable__users') }}
where email = 'glennclose@hoodwinked.com'
    and coalesce(email_list_ids, '') != '[826724,884398]'
