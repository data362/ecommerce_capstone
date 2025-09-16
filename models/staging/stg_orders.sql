with base as (
  select
    order_id,
    customer_id,
    {{ try_to_ts('order_ts') }}                              as order_ts_utc,
    lower(trim(status))                                      as status,
    upper(trim(currency))                                    as currency,
    {{ parse_money('total_amount_text') }}                   as total_amount_num,
    {{ json_text('utm_json','source') }}                     as utm_source,
    {{ json_text('utm_json','medium') }}                     as utm_medium,
    {{ json_text('utm_json','campaign') }}                   as utm_campaign,
    {{ try_to_ts('updated_at') }}                            as updated_at
  from {{ ref('orders_raw') }}
  qualify row_number() over (partition by order_id order by updated_at desc) = 1
),
fx as (
  select * from {{ ref('seed_currency_fx_rates') }}
)
select
  b.*,
  DATE(b.order_ts_utc)                                       as order_date,
  COALESCE(f.usd_rate, 1.0)                                  as usd_rate,
  ROUND(b.total_amount_num * COALESCE(f.usd_rate, 1.0), 2)   as order_total_usd
from base b
left join fx f
  on DATE(b.order_ts_utc) = f.date
  and b.currency = f.currency