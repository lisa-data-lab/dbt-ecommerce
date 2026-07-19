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
        product_name_length as product_name_length,
        product_description_length as product_description_length,
        product_photos_quantity,
        weight_grams as product_weight_g,
        length_cm as product_length_cm,
        height_cm as product_height_cm,
        width_cm as product_width_cm

    from products
)

select * from final