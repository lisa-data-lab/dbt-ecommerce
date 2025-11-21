{{ 
  config(
    materialized='table',
    table_name='int_customer_revenue_monthly'
  ) 
}}

WITH revenue AS (

    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        SUM(total_amount) AS total_revenue,
        MAX(order_date) AS last_order_date
    FROM {{ ref('int_customers_orders') }}
    GROUP BY customer_id

)

SELECT *
FROM revenue

