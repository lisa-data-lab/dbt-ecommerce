{{ config(
    materialized='table',
    file_format='delta',
    liquid_clustering=['performance_month', 'seller_id']
) }}

with order_items as (
    select
        order_id,
        seller_id,
        price,
        freight_value
    from {{ ref('stg_order_items_olist') }}
),

orders as (
    select
        order_id,
        order_status,
        date_trunc('month', cast(purchased_at as date)) as performance_month
    from {{ ref('fact_orders_olist') }}
),

sellers as (
    select
        seller_id,
        seller_city,
        seller_state
    from {{ ref('dim_sellers_olist') }}
),

monthly_metrics as (
    select
        o.performance_month,
        i.seller_id,
        sum(i.price) as total_sales_volume,
        count(i.order_id) as total_items_sold,
        count(distinct o.order_id) as unique_orders_processed,
        sum(i.freight_value) as total_freight_generated
    from order_items i
    inner join orders o on i.order_id = o.order_id
    where o.order_status = 'delivered'
    group by 1, 2
)

select
    m.performance_month,
    m.seller_id,
    s.seller_city,
    s.seller_state,
    m.total_sales_volume,
    m.total_items_sold,
    m.unique_orders_processed,
    m.total_freight_generated,
    round(m.total_sales_volume / nullif(m.unique_orders_processed, 0), 2) as avg_order_value_seller
from monthly_metrics m
left join sellers s on m.seller_id = s.seller_id