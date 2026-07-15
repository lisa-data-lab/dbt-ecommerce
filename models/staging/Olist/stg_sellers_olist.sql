with source_sellers as (

    select * from {{ source('olist', 'sellers') }}

),

renamed as (

    select
        -- Primary Keys
        seller_id,
        
        -- Location Attributes
        cast(seller_zip_code_prefix as int) as zip_code_prefix,
        seller_city as city,
        seller_state as state

    from source_sellers

)

select * from renamed