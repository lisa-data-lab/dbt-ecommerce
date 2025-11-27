SELECT
    customerid
FROM {{ ref('mart_customer_360') }}
WHERE 
    rfm_total_score IS NOT NULL 
    AND value_segment IS NULL