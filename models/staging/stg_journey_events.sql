SELECT
    event_id,
    customer_id,
    campaign_id,
    event_type,
    ts
FROM {{ source('silver_events', 'journey_events') }}
