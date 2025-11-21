{{
  config(
    materialized='table',
    table_name='int_customer_marketing'
  )
}}

WITH first_campaign_window AS (
    -- Compute first campaign touch and first event date per customer using window functions
    SELECT
        je.customer_id,
        je.campaign_id,
        c.channel AS channel,
        je.ts,
        ROW_NUMBER() OVER (PARTITION BY je.customer_id ORDER BY je.ts) AS rn
    FROM {{ ref('stg_journey_events') }} je
    LEFT JOIN {{ ref('stg_dim_campaign') }} c
        ON je.campaign_id = c.campaign_id
),

first_campaign AS (
    -- Pick only the first-touch row per customer
    SELECT
        customer_id,
        campaign_id AS first_campaign_id,
        channel AS channel_first_touch,
        ts AS first_event_date
    FROM first_campaign_window
    WHERE rn = 1
),

customer_cac AS (
    -- Assign marketing spend of the exact day of first touch to each customer
    SELECT
        fc.customer_id,
        fc.first_campaign_id,
        fc.channel_first_touch,
        ms.spend AS acquisition_cost
    FROM first_campaign fc
    LEFT JOIN {{ ref('stg_marketing_spend') }} ms
        ON fc.first_campaign_id = ms.campaign_id
        AND ms.day = DATE(fc.first_event_date)
)

SELECT *
FROM customer_cac

