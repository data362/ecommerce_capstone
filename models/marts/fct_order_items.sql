{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['order_id','product_sku'],
    partition_by={'field':'order_id','data_type':'string'},
    on_schema_change='sync_all_columns',
    tags=['daily_incremental','weekly_refresh']
) }}

with li as (
  select
    oi.order_id,
    oi.product_sku,
    oi.qty,
    oi.unit_price_num,
    oi.line_revenue_usd
  from {{ ref('stg_order_items') }} oi
),
ok as (
  select order_id from {{ ref('fct_orders') }}   -- keep only paid/kept orders
)
select li.*
from li
join ok using (order_id)
{% if is_incremental() %}
  -- optional pruning if items only arrive for recent orders
  where li.order_id in (select order_id from {{ ref('fct_orders') }}
                        where order_ts_utc >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY))
{% endif %}