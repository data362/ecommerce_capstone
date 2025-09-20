select * from {{ ref('ad_spend_batch1') }}
union all 
select * from {{ ref('ad_spend_batch2') }}