{{ config(
    materialized = 'view',
    schema='ecommerce_int'
) }}

SELECT
    DATE(ts) AS event_date,
    COUNT(DISTINCT customer_id) AS dau,
    COUNT(DISTINCT CASE WHEN ts >= DATEADD(day, -7, DATE(ts)) THEN customer_id END) AS wau,
    COUNT(DISTINCT CASE WHEN ts >= DATEADD(day, -30, DATE(ts)) THEN customer_id END) AS mau
FROM {{ ref('stg_journey_events') }}
GROUP BY DATE(ts)
