{{ 
    config(
        materialized='view',
        table_name='int_customer_value_segments',
        description='Customer-level value segmentation using int_customer_base_metrics with RFM scoring and value labels'
    ) 
}}

WITH rfm_scores AS (
    SELECT
        customerid,
        country,
        orders,
        gross_revenue,
        last_purchase,
        DATEDIFF(day, last_purchase, CURRENT_DATE) AS recency_days,

        -- RFM scoring using NTILE
        NTILE(3) OVER (ORDER BY DATEDIFF(day, last_purchase, CURRENT_DATE) ASC) AS recency_score,
        NTILE(3) OVER (ORDER BY orders DESC) AS frequency_score,
        NTILE(3) OVER (ORDER BY gross_revenue DESC) AS monetary_score
    FROM {{ ref('int_customer_base_metrics') }}
),

value_segment AS (
    SELECT
        *,
        (recency_score + frequency_score + monetary_score) AS rfm_total_score,
        CASE
            WHEN (recency_score + frequency_score + monetary_score) >= 8 THEN 'High Value'
            WHEN (recency_score + frequency_score + monetary_score) BETWEEN 5 AND 7 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_segment
    FROM rfm_scores
)

SELECT *
FROM value_segment
