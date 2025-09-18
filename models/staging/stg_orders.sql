-- models/staging/stg_orders.sql

WITH base AS (
  SELECT
    TRIM(CAST(order_id    AS STRING)) AS order_id,
    TRIM(CAST(customer_id AS STRING)) AS customer_id,

    COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(order_ts  AS STRING)),
      SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S%Ez',   CAST(order_ts  AS STRING)),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',      CAST(order_ts  AS STRING))
    ) AS order_ts_utc,

    LOWER(TRIM(CAST(status   AS STRING))) AS status,
    UPPER(TRIM(CAST(currency AS STRING))) AS currency,

    SAFE_CAST(
      REGEXP_REPLACE(TRIM(CAST(total_amount_text AS STRING)), r'[^0-9.\-]', '')
      AS NUMERIC
    ) AS total_amount_num,

    JSON_VALUE(utm_json, '$.source')   AS utm_source,
    JSON_VALUE(utm_json, '$.medium')   AS utm_medium,
    JSON_VALUE(utm_json, '$.campaign') AS utm_campaign,

    COALESCE(
      SAFE.PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%E*S%Ez', CAST(updated_at AS STRING)),
      SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S%Ez',   CAST(updated_at AS STRING)),
      SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S',      CAST(updated_at AS STRING))
    ) AS updated_at
  FROM {{ ref('orders_raw') }}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) = 1
),

fx AS (
  SELECT
    /* Normalize to real DATE + consistent currency for a clean join */
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', CAST(date AS STRING)),
      SAFE.PARSE_DATE('%m/%d/%Y', CAST(date AS STRING)),
      SAFE.PARSE_DATE('%Y/%m/%d', CAST(date AS STRING))
    )                                         AS date,
    UPPER(TRIM(CAST(currency AS STRING)))     AS currency,
    SAFE_CAST(TRIM(CAST(usd_rate AS STRING)) AS NUMERIC) AS usd_rate
  FROM {{ ref('seed_currency_fx_rates') }}
)

SELECT
  b.*,
  DATE(b.order_ts_utc)                                         AS order_date,
  COALESCE(f.usd_rate, 1.0)                                    AS usd_rate,
  ROUND(b.total_amount_num * COALESCE(f.usd_rate, 1.0), 2)     AS order_total_usd
FROM base b
LEFT JOIN fx f
  ON DATE(b.order_ts_utc) = f.date
 AND b.currency          = f.currency
