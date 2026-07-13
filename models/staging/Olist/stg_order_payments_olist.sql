with source_order_payments as (

    select * from {{ source('olist', 'order_payments') }}

),

renamed as (

    select
        -- Primary / Foreign Keys
        order_id,
        
        -- Attributes
        payment_sequential as payment_sequence_number,
        payment_type,
        payment_installments,

        -- Financials
        cast(payment_value as decimal(10, 2)) as payment_value

    from source_order_payments

)

select * from renamed