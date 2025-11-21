-- models/intermediate/int_customer_orders.sql
{{ config(
    schema = 'ecommerce_int',
    materialized = 'table'
) }}

WITH customers_orders AS (
    SELECT
        o.order_id,
        o.order_date,
        o.currency_code,
        o.total_quantity,
        o.total_amount,
        o.item_count,
        o.avg_unit_price,
        b.customer_id
    FROM {{ ref('stg_orders') }} o
    LEFT JOIN {{ source('silver_orders', 'invoice_customer_bridge') }} b
        ON o.order_id = b.invoice_no
)

SELECT *
FROM customers_orders
WHERE customer_id IS NOT NULL

