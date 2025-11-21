{{ config(
    schema='ecommerce_int',
    materialized='table'
) }}

SELECT
    currency_code,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(SUM(total_amount) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS aov
FROM {{ ref('stg_orders') }}
GROUP BY currency_code
