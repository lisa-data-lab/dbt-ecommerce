{{ config(
    materialized='table'
) }}

with customers as (
    select * from {{ ref('stg_customers_olist') }}
),

final as (
    select
        customer_id,
        customer_unique_id,
        zip_code_prefix,
        
        -- Clean up city names (standardizing to title case is often helpful in Gold)
        initcap(city) as customer_city,
        upper(state) as customer_state

    from customers
)

select * from final