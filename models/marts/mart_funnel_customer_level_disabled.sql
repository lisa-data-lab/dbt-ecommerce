-- models/marts/mart_funnel_customers.sql
{{
    config(
        materialized='table',
        table_name='mart_funnel_customer_level',
        enabled=False,
        description='Customer-level funnel metrics per campaign.'
    )
}}

SELECT
    customer_id,
    campaign_id,
    channel,
    first_awareness_ts,
    first_consideration_ts,
    first_conversion_ts,
    
    -- Highest funnel stage reached
    CASE
        WHEN first_conversion_ts IS NOT NULL THEN 'conversion'
        WHEN first_consideration_ts IS NOT NULL THEN 'consideration'
        WHEN first_awareness_ts IS NOT NULL THEN 'awareness'
        ELSE 'none'
    END AS funnel_stage,
    
    is_converted,
    days_to_convert
FROM {{ ref('int_customer_funnel') }}
