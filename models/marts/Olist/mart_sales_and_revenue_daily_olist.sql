{{ config(
    materialized='table',
    file_format='delta',
    liquid_clustering='order_date'
) }}

with orders as (
    select 
        order_id,
        customer_id,
        order_status,
        cast(purchased_at as date) as order_date,
        total_item_price,
        total_freight_value
    from {{ ref('fact_orders_olist') }}
),

order_payments as (
    select 
        order_id,
        total_payment_value
    from {{ ref('int_order_payments_total_olist') }}
),

joined as (
    select
        o.order_date,
        o.order_id,
        o.customer_id,
        o.total_item_price,
        o.total_freight_value,
        op.total_payment_value
    from orders o
    left join order_payments op on o.order_id = op.order_id
    where o.order_status = 'delivered'
)

select
    order_date,
    sum(total_payment_value) as total_revenue,
    sum(total_item_price) as total_sales_value,
    sum(total_freight_value) as total_freight_value,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as unique_customers,
    round(sum(total_payment_value) / nullif(count(distinct order_id), 0), 2) as average_order_value
from joined
group by 1