-- models/staging/stg_customers.sql
WITH raw AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        address_line1,
        city,
        state_province,
        postal_code,
        country,
        phone,
        email_hash
    FROM {{ source('silver_customers', 'dim_customer') }}
)
SELECT
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    TRIM(address_line1) AS address_line1,
    TRIM(city) AS city,
    TRIM(state_province) AS state_province,
    TRIM(postal_code) AS postal_code,
    country,
    phone,
    email_hash
FROM raw
WHERE customer_id IS NOT NULL;
