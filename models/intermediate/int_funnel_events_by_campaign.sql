-- models/intermediate/int_funnel_events_by_campaign.sql
SELECT
    campaign_id,
    funnel_stage,
    COUNT(DISTINCT customer_id) AS user_count
FROM {{ ref('int_funnel_events') }}
GROUP BY campaign_id, funnel_stage
