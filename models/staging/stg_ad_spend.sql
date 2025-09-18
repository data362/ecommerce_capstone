-- models/staging/stg_ad_spend.sql

WITH base AS (
  SELECT
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', CAST(date AS STRING)),
      SAFE.PARSE_DATE('%m/%d/%Y', CAST(date AS STRING)),
      SAFE.PARSE_DATE('%Y/%m/%d', CAST(date AS STRING))
    )                                              AS date,
    LOWER(TRIM(CAST(channel AS STRING)))          AS raw_channel,
    TRIM(CAST(campaign_id AS STRING))             AS campaign_id,
    SAFE_CAST(TRIM(CAST(impressions AS STRING)) AS INT64)  AS impressions,
    SAFE_CAST(TRIM(CAST(clicks      AS STRING)) AS INT64)  AS clicks,
    SAFE_CAST(
      REGEXP_REPLACE(TRIM(CAST(cost_text AS STRING)), r'[^0-9.\-]', '')
      AS NUMERIC
    )                                              AS cost_usd
  FROM {{ ref('ad_spend_raw') }}
),

mapped AS (
  SELECT
    b.*,
    m.canonical_channel,
    COALESCE(m.paid_flag, FALSE) AS paid_flag
  FROM base b
  LEFT JOIN {{ ref('seed_channel_map') }} m
    ON b.raw_channel = LOWER(TRIM(CAST(m.raw_channel AS STRING)))
)

SELECT * FROM mapped
