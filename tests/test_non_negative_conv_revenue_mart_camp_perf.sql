SELECT
    campaign_id,
    total_conversions,
    total_revenue,
    total_spend
FROM {{ ref('mart_campaign_performance') }}
WHERE total_conversions < 0
    OR total_revenue < 0
    OR total_spend < 0