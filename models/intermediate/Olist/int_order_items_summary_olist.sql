with order_items as (

    select * from {{ ref('stg_order_items_olist') }}

),

aggregated as (

    select
        order_id,
        count(*) as total_items,
        sum(cast(price as decimal(10, 2))) as total_item_price,
        sum(cast(freight_value as decimal(10, 2))) as total_freight_value,
        sum(cast(price as decimal(10, 2))) + sum(cast(freight_value as decimal(10, 2))) as total_order_cost

    from order_items
    group by 1

)

select * from aggregated