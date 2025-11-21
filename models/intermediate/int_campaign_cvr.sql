{{ config(
    schema = 'ecommerce_int',
    materialized = 'table'
) }}

WITH customer_engagements AS (
    SELECT
        je.customer_id,
        je.campaign_id,
        COUNT(*) AS total_engagements
    FROM {{ ref('stg_journey_events') }} je
    WHERE je.event_type IN ('email_click', 'push_open', 'sms_click')
    GROUP BY 1, 2
),

customer_orders AS (
    SELECT
        co.order_id,
        co.customer_id,
        co.order_date,
        co.total_amount,
        je.campaign_id
    FROM {{ ref('int_customers_orders') }} co
    LEFT JOIN {{ ref('stg_journey_events') }} je
        ON co.customer_id = je.customer_id
),

campaign_cvr AS (
    SELECT
        e.campaign_id,
        SUM(e.total_engagements) AS total_engagements,
        COUNT(DISTINCT o.order_id) AS total_conversions,
        ROUND(COUNT(DISTINCT o.order_id) / NULLIF(SUM(e.total_engagements), 0), 4) AS cvr
    FROM customer_engagements e
    LEFT JOIN customer_orders o
        ON e.customer_id = o.customer_id
        AND e.campaign_id = o.campaign_id
    GROUP BY e.campaign_id
)

SELECT * FROM campaign_cvr

