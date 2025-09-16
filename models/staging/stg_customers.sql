select
  customer_id,
  INITCAP(TRIM(full_name))                               as full_name_clean,
  LOWER(TRIM(email))                                     as email_norm,
  UPPER(COALESCE(TRIM(country_code), 'US'))              as country_code,
  {{ try_to_ts('created_ts') }}                          as created_ts_utc,
  {{ try_to_ts('updated_at') }}                          as updated_at
from {{ ref('customers_raw') }}