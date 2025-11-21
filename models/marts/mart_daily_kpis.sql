-- models/marts/mart_daily_kpis.sql
{{
    config(
        materialized='table',
        table_name='mart_daily_kpis',
        description='Daily KPIs ready for dashboards, with business-friendly column names'
    )
}}

SELECT
    date,
    
    -- Rename user metrics
    dau   AS DAU,
    wau   AS WAU,
    mau   AS MAU,
    
    -- Rename sales metrics
    total_orders       AS Total_Orders,
    total_conversions  AS Total_Conversions,
    total_revenue      AS Total_Revenue,
    
    -- Rename marketing metrics
    total_spend        AS Total_Spend,
    total_impressions  AS Total_Impressions,
    
    -- Rename and round KPIs
    ROUND(cvr, 4)  AS CVR,
    ROUND(aov, 2)  AS AOV,
    ROUND(roas, 2) AS ROAS

FROM {{ ref('int_daily_kpis') }}
ORDER BY date;

