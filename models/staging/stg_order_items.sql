-- models/staging/stg_order_items.sql

WITH base AS (
  SELECT
    TRIM(CAST(order_id    AS STRING))                           AS order_id,
    TRIM(CAST(product_sku AS STRING))                           AS product_sku,

    SAFE_CAST(
      REGEXP_REPLACE(TRIM(CAST(qty_text AS STRING)), r'[^0-9\-]', '')
      AS INT64
    )                                                           AS qty,

    SAFE_CAST(
      REGEXP_REPLACE(TRIM(CAST(unit_price_text AS STRING)), r'[^0-9.\-]', '')
      AS NUMERIC
    )                                                           AS unit_price_num
  FROM {{ ref('order_items_raw') }}
)

SELECT
  order_id,
  product_sku,
  COALESCE(qty, 0)                                              AS qty,
  unit_price_num,
  ROUND(COALESCE(qty, 0) * unit_price_num, 2)                   AS line_revenue_usd
FROM base
