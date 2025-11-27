{{ config(
    materialized='table',
   ) }}

WITH customer_metrics AS (
    SELECT
        campaign_id,
        channel,
        is_converted,
        days_to_convert,
        CASE WHEN first_awareness_ts IS NOT NULL THEN 1 ELSE 0 END AS reached_awareness,
        CASE WHEN first_consideration_ts IS NOT NULL THEN 1 ELSE 0 END AS reached_consideration,
        CASE WHEN first_conversion_ts IS NOT NULL THEN 1 ELSE 0 END AS reached_conversion
    FROM {{ ref('int_customer_funnel') }}
)
SELECT
    cfc.campaign_id,
    cfc.channel,
    fc.objective,
    fc.start_dt,
    fc.end_dt,
    fc.budget,
    
    SUM(reached_awareness) AS awareness_users,
    SUM(reached_consideration) AS consideration_users,
    SUM(reached_conversion) AS conversion_users,
    
    SUM(reached_consideration) / NULLIF(SUM(reached_awareness), 0) AS rate_awareness_to_consideration,
    SUM(reached_conversion) / NULLIF(SUM(reached_consideration), 0) AS rate_consideration_to_conversion,
    SUM(reached_conversion) / NULLIF(SUM(reached_awareness), 0) AS rate_overall_conversion,
    
    AVG(days_to_convert) AS avg_days_to_convert,
    APPROX_PERCENTILE(days_to_convert, 0.5) AS median_days_to_convert

FROM customer_metrics cfc
LEFT JOIN {{ ref('int_funnel_conversion_by_campaign') }} fc
    ON cfc.campaign_id = fc.campaign_id
GROUP BY
    cfc.campaign_id,
    cfc.channel,
    fc.objective,
    fc.start_dt,
    fc.end_dt,
    fc.budget
ORDER BY cfc.campaign_id;


