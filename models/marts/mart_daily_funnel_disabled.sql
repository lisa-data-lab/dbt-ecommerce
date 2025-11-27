-- models/marts/mart_daily_funnel.sql
{{
    config(
        materialized='table',
        table_name='mart_daily_funnels',
        enabled=false,
        description='Daily funnel snapshot by campaign and stage.'
    )
}}

WITH daily_stage AS (
    SELECT
        campaign_id,
        channel,
        stage AS funnel_stage,
        DATE(stage_ts) AS date,
        COUNT(DISTINCT customer_id) AS daily_users
    FROM {{ ref('int_funnel_events') }}
    GROUP BY 1,2,3,4
),

cumulative_stage AS (
    SELECT
        ds.campaign_id,
        ds.channel,
        ds.funnel_stage,
        ds.date,
        ds.daily_users,
        SUM(ds.daily_users) OVER (
            PARTITION BY ds.campaign_id, ds.channel, ds.funnel_stage
            ORDER BY ds.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_users
    FROM daily_stage ds
)

SELECT
    campaign_id,
    channel,
    funnel_stage,
    date,
    daily_users,
    cumulative_users,
    
    -- Daily conversion rate relative to previous stage
  CASE funnel_stage
    WHEN 'consideration' THEN 
        daily_users / NULLIF(LAG(cumulative_users) OVER (
            PARTITION BY campaign_id, channel ORDER BY date
        ), 0)
    WHEN 'conversion' THEN 
        daily_users / NULLIF(LAG(cumulative_users) OVER (
            PARTITION BY campaign_id, channel ORDER BY date
        ), 0)
    ELSE NULL
END AS daily_conversion_rate


FROM cumulative_stage
ORDER BY campaign_id, funnel_stage, date
