-- Custom data quality test for mart_daily_kpis
-- This test fails if any of the following conditions occur:
-- 1. Duplicate dates
-- 2. Negative metric values
-- 3. KPI ratios outside reasonable ranges

WITH kpi AS (
    SELECT * FROM {{ ref('mart_daily_kpis') }}
),

validations AS (

    SELECT
        date,

        -- Duplicate-date check
        CASE WHEN COUNT(*) OVER (PARTITION BY date) > 1 THEN 'duplicate_date' END AS duplicate_date_error,

        -- Negative values check
        CASE WHEN DAU < 0 THEN 'negative_dau' END AS dau_error,
        CASE WHEN WAU < 0 THEN 'negative_wau' END AS wau_error,
        CASE WHEN MAU < 0 THEN 'negative_mau' END AS mau_error,
        CASE WHEN Total_Orders < 0 THEN 'negative_orders' END AS orders_error,
        CASE WHEN Total_Conversions < 0 THEN 'negative_conversions' END AS conversions_error,
        CASE WHEN Total_Revenue < 0 THEN 'negative_revenue' END AS revenue_error,
        CASE WHEN Total_Spend < 0 THEN 'negative_spend' END AS spend_error,
        CASE WHEN Total_Impressions < 0 THEN 'negative_impressions' END AS impressions_error,

        -- KPI Range checks
        CASE WHEN CVR < 0 OR CVR > 1 THEN 'invalid_cvr_range' END AS cvr_error,
        CASE WHEN AOV < 0 THEN 'invalid_aov' END AS aov_error,
        CASE WHEN ROAS < 0 THEN 'invalid_roas' END AS roas_error

    FROM kpi
)

SELECT *
FROM validations
WHERE
    duplicate_date_error IS NOT NULL OR
    dau_error IS NOT NULL OR
    wau_error IS NOT NULL OR
    mau_error IS NOT NULL OR
    orders_error IS NOT NULL OR
    conversions_error IS NOT NULL OR
    revenue_error IS NOT NULL OR
    spend_error IS NOT NULL OR
    impressions_error IS NOT NULL OR
    cvr_error IS NOT NULL OR
    aov_error IS NOT NULL OR
    roas_error IS NOT NULL;
