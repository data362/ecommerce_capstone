select * from {{ ref('customers_batch1') }}
union all
select * from {{ ref('customers_batch2') }}