select * from {{ ref('orders_batch1') }}
union all
select * from {{ ref('orders_batch2') }}