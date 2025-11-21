{% test mart_daily_kpis_quality(model) %}

-- Combined quality test for mart_daily_kpis
-- Fails if any of the following conditions occur:
-- 1. Nulls in required columns
-- 2. Negative values in numeric metrics
-- 3. Non-integer orders/conversions
-- 4. CVR out of range [0,1]
-- 5. Duplicate dates

WITH kpi AS (
    SELECT * FROM {{ model }}
),

validations AS (

    SELECT
        date,

        -- Duplicate-date check
        CASE WHEN COUNT(*) OVER (PARTITION BY date) > 1 THEN 'duplicate_date' END AS duplicate_date_error,

        -- Null checks
        CASE WHEN Total_Orders IS NULL THEN 'null_total_orders' END AS total_orders_null,
        CASE WHEN Total_Conversions IS NULL THEN 'null_total_conversions' END AS total_conversions_null,
        CASE WHEN Total_Revenue IS NULL THEN 'null_total_revenue' END AS total_revenue_null,
        CASE WHEN Total_Spend IS NULL THEN 'null_total_spend' END AS total_spend_null,
        CASE WHEN Total_Impressions IS NULL THEN 'null_total_impressions' END AS total_impressions_null,
        CASE WHEN CVR IS NULL THEN 'null_cvr' END AS cvr_null,
        CASE WHEN AOV IS NULL THEN 'null_aov' END AS aov_null,
        CASE WHEN ROAS IS NULL THEN 'null_roas' END AS roas_null,

        -- Non-negative checks
        CASE WHEN Total_Orders < 0 THEN 'negative_total_orders' END AS total_orders_neg,
        CASE WHEN Total_Conversions < 0 THEN 'negative_total_conversions' END AS total_conversions_neg,
        CASE WHEN Total_Revenue < 0 THEN 'negative_total_revenue' END AS total_revenue_neg,
        CASE WHEN Total_Spend < 0 THEN 'negative_total_spend' END AS total_spend_neg,
        CASE WHEN Total_Impressions < 0 THEN 'negative_total_impressions' END AS total_impressions_neg,
        CASE WHEN AOV < 0 THEN 'negative_aov' END AS aov_neg,
        CASE WHEN ROAS < 0 THEN 'negative_roas' END AS roas_neg,

        -- Integer checks
        CASE WHEN Total_Orders != floor(Total_Orders) THEN 'total_orders_not_integer' END AS total_orders_int,
        CASE WHEN Total_Conversions != floor(Total_Conversions) THEN 'total_conversions_not_integer' END AS total_conversions_int,

        -- CVR range check
        CASE WHEN CVR < 0 OR CVR > 1 THEN 'cvr_out_of_range' END AS cvr_range_error

    FROM kpi
)

SELECT *
FROM validations
WHERE
    duplicate_date_error IS NOT NULL OR
    total_orders_null IS NOT NULL OR
    total_conversions_null IS NOT NULL OR
    total_revenue_null IS NOT NULL OR
    total_spend_null IS NOT NULL OR
    total_impressions_null IS NOT NULL OR
    cvr_null IS NOT NULL OR
    aov_null IS NOT NULL OR
    roas_null IS NOT NULL OR
    total_orders_neg IS NOT NULL OR
    total_conversions_neg IS NOT NULL OR
    total_revenue_neg IS NOT NULL OR
    total_spend_neg IS NOT NULL OR
    total_impressions_neg IS NOT NULL OR
    aov_neg IS NOT NULL OR
    roas_neg IS NOT NULL OR
    total_orders_int IS NOT NULL OR
    total_conversions_int IS NOT NULL OR
    cvr_range_error IS NOT NULL;

{% endtest %}
