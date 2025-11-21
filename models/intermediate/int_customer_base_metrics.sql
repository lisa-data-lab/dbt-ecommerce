{{ config(
    materialized = 'view',
    schema = 'ecommerce_int'
) }}

-- Intermediate model: enrich customer base metrics from Silver layer
WITH base AS (
    SELECT
        customerid,
        country,
        first_purchase,
        last_purchase,
        orders,
        qty,
        gross_revenue
    FROM {{ source('silver_customers', 'silver_customers_base_metrics') }}
),

-- Add derived metrics for KPI-level marts
enhanced AS (
    SELECT
        customerid,
        country,
        first_purchase,
        last_purchase,
        orders,
        qty,
        gross_revenue,
        ROUND(gross_revenue / NULLIF(orders, 0), 2) AS avg_order_value,
        DATEDIFF(current_date(), last_purchase) AS days_since_last_purchase,
        CASE
            WHEN DATEDIFF(last_purchase, first_purchase) > 0
                THEN ROUND(gross_revenue / DATEDIFF(last_purchase, first_purchase), 2)
            ELSE NULL
        END AS revenue_per_day
    FROM base
)

SELECT * FROM enhanced
