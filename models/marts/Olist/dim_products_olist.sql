{{ config(
    materialized='table'
) }}

with products as (
    select * from {{ ref('stg_products_olist') }}
),

final as (
    select
        product_id,
        -- Replace underscores in category names with spaces and capitalize for clean reporting
        initcap(replace(product_category_name, '_', ' ')) as product_category,
        product_name_lenght as product_name_length,
        product_description_length as product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    from products
)

select * from final