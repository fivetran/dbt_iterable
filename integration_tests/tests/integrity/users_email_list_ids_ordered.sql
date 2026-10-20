{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

-- 9876 sorts last as a string but first as a number, so this fails if ordering is lexicographic or missing.
select *
from {{ ref('iterable__users') }}
where email = 'glennclose@hoodwinked.com'
    and coalesce(email_list_ids, '') != '[9876,826724,884398]'
