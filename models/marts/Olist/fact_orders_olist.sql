with orders as (

    select * from {{ ref('stg_orders_olist') }}

),

order_items_summary as (

    select * from {{ ref('int_order_items_summary_olist') }}

),

order_payments_summary as (

    select * from {{ ref('int_order_payments_total_olist') }}

),

final as (

    select
        -- Keys
        o.order_id,
        o.customer_id,

        -- Status & Timestamps
        o.order_status,
        o.purchased_at,
        o.approved_at,
        o.delivered_to_carrier_at,
        o.delivered_to_customer_at,
        o.estimated_delivery_at,

        -- Item Metrics
        coalesce(i.total_items, 0) as total_items,
        coalesce(i.total_item_price, 0.00) as total_item_price,
        coalesce(i.total_freight_value, 0.00) as total_freight_value,
        coalesce(i.total_order_cost, 0.00) as total_order_cost,

        -- Payment Metrics
        coalesce(p.total_payment_value, 0.00) as total_payment_amount,

        -- Financial Checks / Discrepancies
        coalesce(p.total_payment_value, 0.00) - coalesce(i.total_order_cost, 0.00) as payment_cost_difference

    from orders o
    left join order_items_summary i 
        on o.order_id = i.order_id
    left join order_payments_summary p 
        on o.order_id = p.order_id

)

select * from final