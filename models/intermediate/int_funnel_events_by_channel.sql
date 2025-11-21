-- models/intermediate/int_funnel_events_by_channel.sql
SELECT
    channel,
    funnel_stage,
    COUNT(DISTINCT customer_id) AS user_count
FROM {{ ref('int_funnel_events') }}
GROUP BY channel, funnel_stage
