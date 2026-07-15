with source_products as (

    select * from {{ source('olist', 'products') }}

),

renamed as (

    select
        -- Primary Keys
        product_id,
        
        -- Attributes
        product_category_name,
        cast(product_name_lenght as int) as product_name_length,
        cast(product_description_lenght as int) as product_description_length,
        cast(product_photos_qty as int) as product_photos_quantity,

        -- Physical Dimensions
        cast(product_weight_g as int) as weight_grams,
        cast(product_length_cm as int) as length_cm,
        cast(product_height_cm as int) as height_cm,
        cast(product_width_cm as int) as width_cm

    from source_products

)

select * from renamed