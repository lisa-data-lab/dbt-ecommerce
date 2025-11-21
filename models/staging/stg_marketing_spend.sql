SELECT
    campaign_id,
    day,
    impressions,
    clicks,
    spend
FROM {{ source('silver_campaigns', 'marketing_spend') }}
