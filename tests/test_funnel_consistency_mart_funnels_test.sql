-- tests/test_funnel_consistency_mart_funnels.sql

SELECT
    campaign_id,
    channel,
    awareness_users,
    consideration_users,
    conversion_users
FROM {{ ref('mart_funnels') }}
WHERE NOT (
    -- Rule 1: Awareness users must be greater than or equal to Consideration users
    awareness_users >= consideration_users
    -- Rule 2: Consideration users must be greater than or equal to Conversion users
    AND consideration_users >= conversion_users
)