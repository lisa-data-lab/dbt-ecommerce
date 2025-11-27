SELECT
    campaign_id,
    total_spend,
    roas
FROM {{ ref('mart_campaign_performance') }}
WHERE roas IS NOT NULL
    AND total_spend = 0