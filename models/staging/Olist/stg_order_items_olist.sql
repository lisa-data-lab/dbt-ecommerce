with source_order_items as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        -- Primary / Foreign Keys
        order_id,
        order_item_id as line_item_number,
        product_id,
        seller_id,

        -- Dates / Timestamps
        cast(shipping_limit_date as timestamp) as shipping_limit_at,

        -- Financials
        cast(price as decimal(10, 2)) as price,
        cast(freight_value as decimal(10, 2)) as freight_value

    from source_order_items

)

select * from renamed