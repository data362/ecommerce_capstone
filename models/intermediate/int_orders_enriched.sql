with o as (
  select * from {{ ref('stg_orders') }}
),
c as (
  select * from {{ ref('stg_customers') }}
)
select
  o.order_id,
  o.customer_id,
  o.order_ts_utc,
  o.order_date,
  o.order_total_usd,
  o.status,
  o.utm_source, o.utm_medium, o.utm_campaign,
  c.email_norm, c.country_code,
  (o.status in ('paid','fulfilled')) as is_paid
from o
left join c using (customer_id)