with source_geolocation as (

    select * from {{ source('olist', 'geolocation') }}

),

renamed as (

    select
        -- Attributes
        geolocation_zip_code_prefix as zip_code_prefix,
        geolocation_lat as latitude,
        geolocation_lng as longitude,
        geolocation_city as city,
        geolocation_state as state

    from source_geolocation

)

select * from renamed