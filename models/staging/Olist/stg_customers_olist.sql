with source_customers as (

    select * from {{ source('olist', 'customers') }}

),

renamed as (

    select
        -- Primary Key
        customer_id,

        -- Foreign / Unique Keys
        customer_unique_id,

        -- Attributes
        customer_zip_code_prefix as zip_code_prefix,
        customer_city as city,
        customer_state as state

    from source_customers

)

select * from renamed