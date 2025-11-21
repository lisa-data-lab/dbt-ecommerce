{{
    config(
        materialized='table',
        table_name='int_daily_conversions',
        description='Daily metrics: total orders, total revenue, total customer conversions'
    )
}}

-- Aggregate orders per day
WITH daily_orders AS (
    SELECT
        DATE(order_date) AS date,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS total_revenue
    FROM {{ ref('int_customers_orders') }}
    GROUP BY 1
),

-- Aggregate customer conversions per day
daily_conversions AS (
    SELECT
        DATE(first_conversion_ts) AS date,
        COUNT(DISTINCT customer_id) AS total_conversions
    FROM {{ ref('int_customer_funnel') }}
    WHERE is_converted = TRUE
      AND first_conversion_ts IS NOT NULL
    GROUP BY 1
)

-- Combine orders and conversions
SELECT
    do.date,
    do.total_orders,
    dc.total_conversions,
    do.total_revenue
FROM daily_orders do
LEFT JOIN daily_conversions dc USING (date)
ORDER BY do.date;
