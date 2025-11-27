WITH pivoted AS (
    SELECT
        campaign_id,
        MAX(CASE WHEN funnel_stage = 'awareness' THEN user_count END) AS awareness_users,
        MAX(CASE WHEN funnel_stage = 'consideration' THEN user_count END) AS consideration_users,
        MAX(CASE WHEN funnel_stage = 'conversion' THEN user_count END) AS conversion_users
    FROM {{ ref('int_funnel_events_by_campaign') }}
    GROUP BY campaign_id
),

metrics AS (
    SELECT
        p.campaign_id,
        d.channel,
        d.objective,
        d.budget,
        TO_DATE(d.start_dt) AS start_dt,
        TO_DATE(d.end_dt) AS end_dt,
        COALESCE(awareness_users,0) AS awareness_users,
        COALESCE(consideration_users,0) AS consideration_users,
        COALESCE(conversion_users,0) AS conversion_users,
        ROUND(COALESCE(consideration_users,0) * 1.0 / NULLIF(COALESCE(awareness_users,0),0),4) AS rate_awareness_to_consideration,
        ROUND(COALESCE(conversion_users,0) * 1.0 / NULLIF(COALESCE(consideration_users,0),0),4) AS rate_consideration_to_conversion,
        ROUND(COALESCE(conversion_users,0) * 1.0 / NULLIF(COALESCE(awareness_users,0),0),4) AS rate_overall_conversion
    FROM pivoted p
    LEFT JOIN {{ ref('stg_dim_campaign') }} d
      ON p.campaign_id = d.campaign_id
)

SELECT * FROM metrics;

