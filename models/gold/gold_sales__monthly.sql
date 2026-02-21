{{ config(materialized='view') }}

with orders as (
  select * from {{ ref('stg_orders') }}
),
items as (
  select * from {{ ref('fct_order_items') }}
),
products as (
  select * from {{ ref('stg_products') }}
),
joined as (
  select
    date_trunc('month', o.order_ts) as month_start,
    i.order_id,
    i.product_id,
    i.qty,
    p.unit_price,
    (i.qty * p.unit_price) as line_amount
  from orders o
  join items i on i.order_id = o.order_id
  join products p on p.product_id = i.product_id
)
select
  month_start,
  count(distinct order_id) as orders,
  sum(qty) as units,
  cast(sum(line_amount) as double) as revenue
from joined
group by month_start
