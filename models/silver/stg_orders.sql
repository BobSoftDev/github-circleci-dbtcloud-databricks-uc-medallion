select
  cast(order_id as bigint) as order_id,
  cast(customer_id as bigint) as customer_id,
  cast(order_ts as timestamp) as order_ts
from {{ ref('orders') }}
