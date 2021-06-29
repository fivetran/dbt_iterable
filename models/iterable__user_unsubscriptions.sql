with message_type_channel as (

    select *
    from {{ ref('int_iterable__message_type_channel') }}

), 