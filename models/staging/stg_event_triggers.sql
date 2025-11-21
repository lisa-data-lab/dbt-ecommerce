SELECT
    customer_id,
    trigger_type,
    reason,
    valid_from,
    valid_to,
    status,
    policy_version
FROM {{ source('silver_campaigns', 'event_triggers') }}
