-- models/staging/stg_order_items.sql
WITH raw AS (
    SELECT
        order_id,
        product_id,
        quantity,
        unit_price,
        line_total,
        order_date,
        currency_code
    FROM {{ source('silver_orders', 'fact_order_items') }}
)
SELECT
    order_id,
    product_id,
    CAST(quantity AS INT) AS quantity,
    CAST(unit_price AS DECIMAL(18,2)) AS unit_price,
    CAST(line_total AS DECIMAL(18,2)) AS line_total,
    CAST(order_date AS DATE) AS order_date,
    currency_code
FROM raw
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL;
