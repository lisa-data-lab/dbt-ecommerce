{{ config(
    schema='ecommerce_int',
    materialized='table',
    alias='int_aov_by_campaign'
) }}

WITH customer_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.total_amount,
        o.currency_code,
        je.campaign_id
    FROM {{ ref('int_customers_orders') }} o
    LEFT JOIN {{ ref('stg_journey_events') }} je
        ON o.customer_id = je.customer_id
)

SELECT
    campaign_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(SUM(total_amount) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS aov
FROM customer_orders
WHERE campaign_id IS NOT NULL
GROUP BY campaign_id
ORDER BY aov DESC
