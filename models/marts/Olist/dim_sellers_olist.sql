{{ config(
    materialized='table'
) }}

with sellers as (
    select * from {{ ref('stg_sellers_olist') }}
),

final as (
    select
        seller_id,
        zip_code_prefix as seller_zip_code_prefix,
        
        -- Clean up city and state names for presentation
        initcap(city) as seller_city,
        upper(state) as seller_state

    from sellers
)

select * from final