{{
    config(
        materialized = 'table',
        schema='ecommerce_int'
    )
}}

-- 1. Base table of unique user activity per day
WITH daily_user_base AS (
    SELECT
        CAST(DATE(ts) AS DATE) AS date,
        customer_id
    FROM {{ ref('stg_journey_events') }}
    GROUP BY 1, 2 -- Ensures one row per customer per day
),

-- 2. Simple Daily Aggregation (to correctly calculate DAU)
daily_aggregation AS (
    SELECT
        date,
        COUNT(customer_id) AS dau -- DAU is COUNT of customers in daily_user_base
    FROM daily_user_base
    GROUP BY 1
),

-- 3. Rolling Metrics (The complex, fixed logic for WAU/MAU)
rolling_metrics AS (
    SELECT
        t1.date,
        COUNT(DISTINCT t2.customer_id) AS wau,
        COUNT(DISTINCT t3.customer_id) AS mau
    FROM daily_user_base t1
    
    -- Self-join for WAU (7-day window)
    INNER JOIN daily_user_base t2
        ON t2.date BETWEEN DATE_SUB(t1.date, 6) AND t1.date
    
    -- Self-join for MAU (30-day window)
    INNER JOIN daily_user_base t3
        ON t3.date BETWEEN DATE_SUB(t1.date, 29) AND t1.date
    
    GROUP BY 1
)

-- Final Selection: Join the DAU and the Rolling Metrics
SELECT
    da.date AS event_date,
    da.dau,
    rm.wau,
    rm.mau
FROM daily_aggregation da
INNER JOIN rolling_metrics rm
    ON da.date = rm.date
ORDER BY 1