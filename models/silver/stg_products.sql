select
  cast(product_id as bigint) as product_id,
  trim(product_name) as product_name,
  trim(category) as category,
  cast(unit_price as double) as unit_price
from {{ ref('products') }}
