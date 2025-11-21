-- models/intermediate/int_daily_marketing.sql
{{
    config(
        materialized='table',
        table_name='int_daily_marketing_metrics',
        description='Daily aggregated marketing metrics: total spend and total impressions'
    )
}}

SELECT
    day AS date,
    campaign_id,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions
FROM {{ ref('stg_marketing_spend') }}
GROUP BY 1,2
ORDER BY 1,2;
