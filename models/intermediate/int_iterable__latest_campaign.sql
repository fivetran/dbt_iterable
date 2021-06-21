with campaign_history as (
  select *
  from {{ ref('stg_iterable__campaign_history') }}

), latest_campaign as (
    select
      *,
      row_number() over(partition by campaign_id order by updated_at desc) as latest_campaign_index
    from campaign_history
)

-- future consideration: create a time-based campaign metrics table that actually makes use of campaign history

select *
from latest_campaign
where latest_campaign_index = 1
