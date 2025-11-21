SELECT
    campaign_id,
    channel,
    start_dt,
    end_dt,
    objective,
    budget
FROM {{ source('silver_campaigns', 'dim_campaign') }}
