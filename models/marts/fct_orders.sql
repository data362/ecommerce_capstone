{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='order_id',
    partition_by={'field': 'order_ts_utc', 'data_type': 'timestamp', 'granularity': 'day'},
    cluster_by=['customer_id'],
    on_schema_change='sync_all_columns',
    tags=['daily_incremental','weekly_refresh']
) }}

with o as (select * from {{ ref('int_orders_enriched') }} where is_paid)
select * from o
{% if is_incremental() %}
  where o.order_ts_utc >= TIMESTAMP_SUB((select max(order_ts_utc) from {{ this }}), INTERVAL 7 DAY)
{% endif %}