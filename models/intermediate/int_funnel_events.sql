-- models/intermediate/int_funnel_events.sql
WITH base_events AS (
    SELECT
        e.customer_id,
        e.campaign_id,
        c.channel,
        CASE
            WHEN e.event_type IN ('email_open', 'push_open', 'sms_open') THEN 'awareness'
            WHEN e.event_type IN ('email_click', 'sms_click') THEN 'consideration'
        END AS funnel_stage,
        e.ts AS stage_ts
    FROM {{ ref('stg_journey_events') }} e
    LEFT JOIN {{ ref('stg_dim_campaign') }} c
        ON e.campaign_id = c.campaign_id
),

-- 🧩 Attribute orders to last-touch campaign (and derive channel from campaign)
orders_with_campaign AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date AS stage_ts,
        ca.campaign_id,
        d.channel,
        'conversion' AS funnel_stage,
        ROW_NUMBER() OVER (
            PARTITION BY o.order_id
            ORDER BY ca.ts DESC
        ) AS rn
    FROM {{ ref('int_customers_orders') }} o
    JOIN {{ ref('stg_journey_events') }} ca
        ON o.customer_id = ca.customer_id
        AND ca.ts <= o.order_date
    LEFT JOIN {{ ref('stg_dim_campaign') }} d
        ON ca.campaign_id = d.campaign_id
),

last_touch_orders AS (
    SELECT
        customer_id,
        order_id,
        stage_ts,
        campaign_id,
        channel,
        funnel_stage
    FROM orders_with_campaign
    WHERE rn = 1
),

unioned AS (
    SELECT
        customer_id,
        campaign_id,
        channel,
        funnel_stage,
        stage_ts
    FROM base_events

    UNION ALL

    SELECT
        customer_id,
        campaign_id,
        channel,
        funnel_stage,
        stage_ts
    FROM last_touch_orders
)

SELECT
    customer_id,
    campaign_id,
    channel,
    funnel_stage,
    stage_ts
FROM unioned;

