-- models/staging/stg_orders.sql
SELECT
    order_id,
    order_date,
    currency_code,
    total_quantity,
    total_amount,
    item_count,
    avg_unit_price
FROM {{ source('silver_orders', 'fact_orders') }}
WHERE order_id IS NOT NULL;
