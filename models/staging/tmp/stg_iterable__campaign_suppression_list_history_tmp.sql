{{ config(enabled=var('iterable__using_campaign_suppression_list_history', True)) }}

select *
from {{ var('campaign_suppression_list_history') }}
