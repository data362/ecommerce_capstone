{% snapshot snap_dim_customer %}
  {{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='timestamp',
      updated_at='updated_at'
    )
  }}
  select
    customer_id,
    full_name_clean,
    email_norm,
    country_code,
    updated_at
  from {{ ref('stg_customers') }}
{% endsnapshot %}


