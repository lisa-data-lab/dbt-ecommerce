{{ 
    config(
        materialized='view',
        table_name='int_cohort_metrics',
        description='Cohort-level metrics including customer counts, conversion rate, and revenue aggregated by acquisition month'
    ) 
}}

WITH customer_cohort AS (
    SELECT
        customerid,
        DATE_TRUNC('month', first_purchase) AS cohort_month,
        is_converted,
        gross_revenue
    FROM {{ ref('int_customer_base_metrics') }} cbm
    LEFT JOIN {{ ref('int_customer_funnel') }} cf
      ON cbm.customerid = cf.customer_id
),

cohort_metrics AS (
    SELECT
        cohort_month,
        COUNT(customerid) AS customers_in_cohort,
        SUM(CASE WHEN is_converted THEN 1 ELSE 0 END) AS converted_customers,
        ROUND(SUM(CASE WHEN is_converted THEN 1 ELSE 0 END)::decimal / COUNT(customerid), 4) AS conversion_rate,
        SUM(gross_revenue) AS total_revenue,
        ROUND(SUM(gross_revenue)::decimal / COUNT(customerid), 2) AS avg_revenue_per_customer
    FROM customer_cohort
    GROUP BY cohort_month
    ORDER BY cohort_month
)

SELECT *
FROM cohort_metrics
