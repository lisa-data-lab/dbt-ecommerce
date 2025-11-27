SELECT
    customerid,
    first_awareness_ts,
    first_consideration_ts,
    first_conversion_ts
FROM {{ ref('mart_customer_360') }}
WHERE
    (first_consideration_ts < first_awareness_ts)
    OR (first_conversion_ts < first_consideration_ts)