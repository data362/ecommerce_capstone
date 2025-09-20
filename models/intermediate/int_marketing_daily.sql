with cleaned as (
  select
    date,
    canonical_channel,
    campaign_id,
    impressions,
    clicks,
    cost_usd
  from {{ ref('stg_ad_spend') }}
)
select
  date,
  canonical_channel,
  campaign_id,
  sum(impressions) as impressions,
  sum(clicks)      as clicks,
  sum(cost_usd)    as cost_usd,
  SAFE_DIVIDE(sum(clicks),      NULLIF(sum(impressions),0))         as ctr,
  SAFE_DIVIDE(sum(cost_usd),    NULLIF(sum(clicks),0))              as cpc,
  SAFE_DIVIDE(1000*sum(cost_usd), NULLIF(sum(impressions),0))       as cpm
from cleaned
group by 1,2,3