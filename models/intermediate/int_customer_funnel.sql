-- models/intermediate/int_customer_funnel.sql
{{ 
    config(
        materialized='view',      
        table_name='int_customer_funnel',  
        description='Customer-level funnel summary with first timestamps for each stage, conversion flag, and days_to_convert'
    ) 
}}


WITH stage_times AS (
    SELECT
        customer_id,
        campaign_id,
        channel,
        MIN(CASE WHEN funnel_stage = 'awareness' THEN stage_ts END) AS first_awareness_ts,
        MIN(CASE WHEN funnel_stage = 'consideration' THEN stage_ts END) AS first_consideration_ts,
        MIN(CASE WHEN funnel_stage = 'conversion' THEN stage_ts END) AS first_conversion_ts
    FROM {{ ref('int_funnel_events') }}
    GROUP BY customer_id, campaign_id, channel
),

derived AS (
    SELECT
        *,
        CASE WHEN first_conversion_ts IS NOT NULL THEN TRUE ELSE FALSE END AS is_converted,
        DATEDIFF(
            day,
            first_awareness_ts,
            first_conversion_ts
        ) AS days_to_convert
    FROM stage_times
)

SELECT
    customer_id,
    campaign_id,
    channel,
    first_awareness_ts,
    first_consideration_ts,
    first_conversion_ts,
    is_converted,
    days_to_convert
FROM derived
