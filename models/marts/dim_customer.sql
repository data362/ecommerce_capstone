with snap as (
  select *
  from {{ ref('snap_dim_customer') }}
  where dbt_valid_to is null
)
select
  customer_id,
  full_name_clean,
  email_norm,
  country_code,
  dbt_valid_from as valid_from
from snap