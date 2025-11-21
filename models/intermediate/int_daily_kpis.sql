-- models/intermediate/int_daily_kpis.sql
{{
    config(
        materialized='table',
        table_name='int_daily_kpis',
        description='Daily KPIs combining user activity, customer conversions, and marketing metrics'
    )
}}

WITH daily_marketing AS (
    SELECT
        date,
        SUM(total_spend) AS total_spend,
        SUM(total_impressions) AS total_impressions
    FROM {{ ref('int_daily_marketing_metrics') }}
    GROUP BY date
)

SELECT
    ua.event_date AS date,
    ua.dau,
    ua.wau,
    ua.mau,
    coalesce(dc.total_orders, 0) AS total_orders,
    coalesce(dc.total_conversions, 0) AS total_conversions,
    coalesce(dc.total_revenue, 0) AS total_revenue,
    dm.total_spend,
    dm.total_impressions,

    -- KPI calculations
    ROUND(coalesce(dc.total_conversions, 0) / NULLIF(ua.dau, 0), 4) AS cvr,
    ROUND(coalesce(dc.total_revenue, 0) / NULLIF(coalesce(dc.total_orders, 0), 0), 2) AS aov,
    ROUND(coalesce(dc.total_revenue, 0) / NULLIF(dm.total_spend, 0), 2) AS roas

FROM {{ ref('int_user_activity') }} ua
LEFT JOIN {{ ref('int_daily_conversions') }} dc
    ON ua.event_date = dc.date
LEFT JOIN daily_marketing dm
    ON ua.event_date = dm.date
ORDER BY ua.event_date;
