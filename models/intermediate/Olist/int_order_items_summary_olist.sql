with order_items as (

    select * from {{ ref('stg_order_items_olist') }}

),

aggregated as (

    select
        order_id,
        count(order_item_id) as total_items,
        sum(price) as total_item_price,
        sum(freight_value) as total_freight_value,
        sum(price) + sum(freight_value) as total_order_cost

    from order_items
    group by 1

)

select * from aggregated