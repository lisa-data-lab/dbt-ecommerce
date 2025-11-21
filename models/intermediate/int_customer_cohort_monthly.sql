{{ config(
    materialized='table',
    table_name='int_customer_cohort_monthly'
) }}

WITH base AS (

    SELECT
        customerid,
        first_purchase AS first_order_date,
        DATE_TRUNC('month', first_purchase) AS cohort_month
    FROM {{ ref('int_customer_base_metrics') }}

)

SELECT *
FROM base
