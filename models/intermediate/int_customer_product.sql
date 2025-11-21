{{
  config(
    materialized='table',
    table_name='int_customer_product'
  )
}}

WITH customer_products AS (

    SELECT
        o.customer_id,
        oi.product_id,
        p.description AS product_description,
        SUM(oi.quantity) AS total_quantity
    FROM {{ ref('int_customers_orders') }} o
    JOIN {{ ref('stg_order_items') }} oi
        ON o.order_id = oi.order_id
    JOIN {{ ref('stg_products_dim') }} p
        ON oi.product_id = p.stockcode
    GROUP BY o.customer_id, oi.product_id, p.description

),

ranked_products AS (

    SELECT
        customer_id,
        product_id,
        product_description,
        total_quantity,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_quantity DESC) AS rank
    FROM customer_products

)

SELECT
    customer_id,
    product_id AS favorite_product_id,
    product_description AS favorite_product_description,
    COUNT(DISTINCT product_id) AS total_products_purchased
FROM ranked_products
WHERE rank = 1
GROUP BY customer_id, product_id, product_description
