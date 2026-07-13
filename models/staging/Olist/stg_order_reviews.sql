with source_order_reviews as (

    select * from {{ source('olist', 'order_reviews') }}

),

renamed as (

    select
        -- Primary / Foreign Keys
        review_id,
        order_id,
        
        -- Review Attributes
        cast(review_score as int) as review_score,
        review_comment_title as comment_title,
        review_comment_message as comment_message,

        -- Timestamps
        cast(review_creation_date as timestamp) as created_at,
        cast(review_answer_timestamp as timestamp) as answered_at

    from source_order_reviews

)

select * from renamed