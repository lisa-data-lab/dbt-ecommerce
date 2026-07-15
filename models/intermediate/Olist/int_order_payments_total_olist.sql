with payments as (
    select * from {{ ref('stg_order_payments_olist') }}
),

rolled_up_payments as (
    select
        order_id,
        -- Aggregated transaction values
        sum(payment_value) as total_payment_value,
        max(payment_sequence_number) as total_payment_sequences,
        max(payment_installments) as max_payment_installments,

        -- Payment method indicator flags (useful for payment dashboard breakdown)
        max(case when payment_type = 'credit_card' then 1 else 0 end) as has_credit_card,
        max(case when payment_type = 'boleto' then 1 else 0 end) as has_boleto,
        max(case when payment_type = 'voucher' then 1 else 0 end) as has_voucher,
        max(case when payment_type = 'debit_card' then 1 else 0 end) as has_debit_card,
        
        -- Fallback check for any undefined type
        max(case when payment_type not in ('credit_card', 'boleto', 'voucher', 'debit_card') then 1 else 0 end) as has_other_payment_method

    from payments
    group by 1
)

select * from rolled_up_payments