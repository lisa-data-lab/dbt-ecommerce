{{ config(
    schema='ecommerce_int',
    materialized='table'
) }}

WITH orders_with_campaign AS (
    SELECT
        co.order_id,
        co.customer_id,
        co.total_amount,
        je.campaign_id
    FROM {{ ref('int_customers_orders') }} co
    LEFT JOIN {{ ref('stg_journey_events') }} je
        ON co.customer_id = je.customer_id
),

campaign_revenue AS (
    SELECT
        campaign_id,
        SUM(total_amount) AS total_revenue
    FROM orders_with_campaign
    GROUP BY campaign_id
),

campaign_spend AS (
    SELECT
        campaign_id,
        SUM(spend) AS total_spend
    FROM {{ ref('stg_marketing_spend') }}
    GROUP BY campaign_id
)

SELECT
    cr.campaign_id,
    cr.total_revenue,
    cs.total_spend,
    ROUND(cr.total_revenue / NULLIF(cs.total_spend,0), 2) AS roas
FROM campaign_revenue cr
LEFT JOIN campaign_spend cs
    ON cr.campaign_id = cs.campaign_id
