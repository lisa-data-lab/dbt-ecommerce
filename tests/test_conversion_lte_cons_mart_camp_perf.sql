SELECT
    campaign_id,
    conversion_users,
    consideration_users
FROM {{ ref('mart_campaign_performance') }}
WHERE conversion_users > consideration_users