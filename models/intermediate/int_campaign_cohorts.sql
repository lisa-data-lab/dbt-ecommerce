{{ config(
materialized='table',
table_name='int_campaign_cohorts',
description='Aggregated cohort-level metrics by campaign based on first_conversion_ts'
) }}

WITH customer_cohorts AS (
SELECT
customer_id,
campaign_id,
DATE_TRUNC('month', first_conversion_ts) AS cohort_month,
is_converted,
days_to_convert
FROM {{ ref('int_customer_funnel') }}
WHERE first_conversion_ts IS NOT NULL  -- only assign cohorts to customers who converted
),

cohort_aggregates AS (
SELECT
campaign_id,
cohort_month,
COUNT(DISTINCT customer_id) AS customer_count,
SUM(CASE WHEN is_converted THEN 1 ELSE 0 END) AS conversions,
AVG(days_to_convert) AS avg_days_to_convert
FROM customer_cohorts
GROUP BY 1,2
)

SELECT
campaign_id,
cohort_month,
customer_count,
conversions,
avg_days_to_convert
FROM cohort_aggregates
ORDER BY campaign_id, cohort_month
