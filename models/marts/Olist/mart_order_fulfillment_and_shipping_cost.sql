with orders as (
    select * from {{ ref('fact_orders_olist') }}
),

customers as (
    select * from {{ ref('dim_customers_olist') }}
),

sellers as (
    select * from {{ ref('dim_sellers_olist') }}
),

order_items as (
    select * from {{ ref('stg_order_items_olist') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        c.customer_state,
        s.seller_state,
        o.order_status,
        o.purchased_at,
        o.approved_at,
        o.delivered_to_carrier_at,
        o.delivered_to_customer_at,
        o.estimated_delivery_at,
        
        -- Delivery Metrics
        datediff(o.delivered_to_customer_at, o.purchased_at) as actual_delivery_lead_time_days,
        datediff(o.estimated_delivery_at, o.purchased_at) as estimated_delivery_lead_time_days,
        
        -- SLA Breaches
        case 
            when o.delivered_to_customer_at > o.estimated_delivery_at then 1 
            else 0 
        end as is_delivered_late,
        
        datediff(o.delivered_to_customer_at, o.estimated_delivery_at) as days_late

    from orders o
        left join customers c on o.customer_id = c.customer_id
        left join order_items oi on o.order_id = oi.order_id
        left join sellers s on oi.seller_id = s.seller_id
)

select * from final