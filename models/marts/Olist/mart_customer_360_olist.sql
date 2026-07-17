{{ config(
    materialized='table'
) }}

with customers as (
    select * from {{ ref('dim_customers_olist') }}
),

orders as (
    select * from {{ ref('fact_orders_olist') }}
),

customer_orders as (
    select
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        
        -- Aggregating metrics per unique physical customer
        count(distinct o.order_id) as total_orders,
        sum(o.total_items) as total_items_purchased,
        sum(o.total_payment_amount) as total_customer_spend,
        
        -- High-level indicators
        min(o.purchased_at) as first_order_date,
        max(o.purchased_at) as last_order_date

    from orders o
    inner join customers c 
        on o.customer_id = c.customer_id
    group by 1, 2, 3
)

select * from customer_orders