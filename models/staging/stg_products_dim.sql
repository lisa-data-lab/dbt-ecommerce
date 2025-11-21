SELECT
    stockcode,
    description,
    avg_unit_price,
    first_seen,
    last_seen,
    total_qty
FROM {{ source('silver_products', 'dim_product') }}
