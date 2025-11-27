SELECT
    customerid,
    lifetime_value,
    acquisition_cost
FROM {{ ref('mart_customer_360') }}
WHERE lifetime_value < acquisition_cost