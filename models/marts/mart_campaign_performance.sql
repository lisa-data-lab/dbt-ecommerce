{{
    config(
        materialized='table',
        alias='mart_campaign_performance',
        description='Comprehensive campaign performance summary including funnel, cohort, conversion, and ROI metrics.'
    )
}}

WITH base AS (
    SELECT
        fcb.campaign_id,
        fcb.channel,
        fcb.objective,
        fcb.budget,
        fcb.start_dt,
        fcb.end_dt,
        fcb.awareness_users,
        fcb.consideration_users,
        fcb.conversion_users,
        fcb.rate_awareness_to_consideration,
        fcb.rate_consideration_to_conversion,
        fcb.rate_overall_conversion,

        cvr.total_engagements,
        cvr.total_conversions,
        cvr.cvr,

        coh.customer_count,
        coh.conversions AS cohort_conversions,
        coh.avg_days_to_convert,

        aov.total_orders,
        aov.total_revenue,
        aov.aov,

        roas.total_spend,
        roas.roas
    FROM {{ ref('int_funnel_conversion_by_campaign') }} fcb
    LEFT JOIN {{ ref('int_campaign_cvr') }} cvr
        ON fcb.campaign_id = cvr.campaign_id
    LEFT JOIN {{ ref('int_campaign_cohorts') }} coh
        ON fcb.campaign_id = coh.campaign_id
    LEFT JOIN {{ ref('int_aov_by_campaign') }} aov
        ON fcb.campaign_id = aov.campaign_id
    LEFT JOIN {{ ref('int_campaign_roas') }} roas
        ON fcb.campaign_id = roas.campaign_id
)

SELECT
    *,
    total_spend / NULLIF(total_conversions, 0) AS cac,
    total_spend / NULLIF(cohort_conversions, 0) AS spend_per_conversion,
    total_revenue / NULLIF(total_conversions, 0) AS revenue_per_conversion,
    (total_revenue / NULLIF(total_conversions, 0)) / 
    (total_spend / NULLIF(total_conversions, 0)) AS ltv_to_cac_ratio
FROM base
