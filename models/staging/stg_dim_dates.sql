SELECT
    date_key,
    year,
    quarter,
    month,
    day,
    day_of_week,
    week_of_year,
    month_name,
    day_name
FROM {{ source('silver_dates', 'dim_date') }}
