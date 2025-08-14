{{ config(enabled=var('iterable__using_campaign_label_history', True)) }}

select *
from {{ var('campaign_label_history') }}
