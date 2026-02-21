select
  cast(oi.order_item_id as bigint) as order_item_id,
  cast(oi.order_id as bigint) as order_id,
  cast(oi.product_id as bigint) as product_id,
  cast(oi.qty as bigint) as qty
from {{ ref('order_items') }} oi
