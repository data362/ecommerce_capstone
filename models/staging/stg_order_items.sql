with base as (
  select
    order_id,
    product_sku,
    SAFE_CAST(REGEXP_REPLACE(TRIM(qty_text), r'[^0-9]', '') AS INT64)              as qty,
    {{ parse_money('unit_price_text') }}                                           as unit_price_num
  from {{ ref('order_items_raw') }}
)
select
  order_id,
  product_sku,
  COALESCE(qty, 0)                                                                  as qty,
  unit_price_num,
  ROUND(COALESCE(qty,0) * unit_price_num, 2)                                        as line_revenue_usd
from base