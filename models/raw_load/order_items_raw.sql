select * from {{ ref('order_items_batch1') }}
union all
select * from {{ ref('order_items_batch2') }}