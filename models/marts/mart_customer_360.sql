{{
config(
materialized='table',
table_name='mart_customer_360',
description='360° view of each customer including derived metrics: LTV and average days between orders.'
)
}}

WITH base AS (
SELECT
cbm.customerid,
cbm.country,
cbm.first_purchase,
cbm.last_purchase,
cbm.avg_order_value,
cbm.days_since_last_purchase,
cbm.revenue_per_day
FROM {{ ref('int_customer_base_metrics') }} cbm
),

cohort AS (
SELECT
customerid,
cohort_month
FROM {{ ref('int_customer_cohort_monthly') }}
),

funnel AS (
SELECT
customer_id,
campaign_id,
channel,
first_awareness_ts,
first_consideration_ts,
first_conversion_ts,
is_converted,
days_to_convert,
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY first_awareness_ts ASC, first_conversion_ts ASC
    ) as funnel_rank
FROM {{ ref('int_customer_funnel') }}
),

marketing AS (
SELECT
customer_id,
first_campaign_id,
channel_first_touch,
acquisition_cost
FROM {{ ref('int_customer_marketing') }}
),

product AS (
SELECT
customer_id,
favorite_product_id,
favorite_product_description,
total_products_purchased
FROM {{ ref('int_customer_product') }}
),

value AS (
SELECT
customerid,
value_segment,
recency_days,
recency_score,
frequency_score,
monetary_score,
rfm_total_score
FROM {{ ref('int_customer_value_segments') }}
),

orders_agg AS (
SELECT
customer_id,
COUNT(DISTINCT order_id) AS total_orders,
SUM(total_quantity) AS total_quantity,
SUM(total_amount) AS total_spent,
AVG(avg_unit_price) AS avg_unit_price,
AVG(item_count) AS avg_items_per_order
FROM {{ ref('int_customers_orders') }}
GROUP BY customer_id
),

postal AS (
SELECT
customer_id,
postal_code
FROM {{ ref('stg_customers') }}
)

SELECT
any_value(b.customerid) AS customerid,
any_value(b.country) AS country,
any_value(p.postal_code) AS postal_code,
any_value(c.cohort_month) AS cohort_month,
any_value(b.first_purchase) AS first_purchase,
any_value(b.last_purchase) AS last_purchase,
any_value(b.avg_order_value) AS avg_order_value,
any_value(b.days_since_last_purchase) AS days_since_last_purchase,
any_value(b.revenue_per_day) AS revenue_per_day,
any_value(f.campaign_id) AS campaign_id,
any_value(f.channel) AS funnel_channel,
any_value(f.first_awareness_ts) AS first_awareness_ts, -- Kept as-is, already in GROUP BY
any_value(f.first_consideration_ts) AS first_consideration_ts,
any_value(f.first_conversion_ts) AS first_conversion_ts, -- Kept as-is, already in GROUP BY
any_value(f.is_converted) AS is_converted,
CASE 
    WHEN any_value(f.first_conversion_ts) < any_value(f.first_awareness_ts)
    THEN NULL -- Set to NULL for logically impossible conversion
    ELSE any_value(f.days_to_convert)
END AS days_to_convert,
any_value(m.first_campaign_id) AS first_campaign_id,
any_value(m.channel_first_touch) AS channel_first_touch,
any_value(m.acquisition_cost) AS acquisition_cost,
any_value(pr.favorite_product_id) AS favorite_product_id,
any_value(pr.favorite_product_description) AS favorite_product_description,
any_value(pr.total_products_purchased) AS total_products_purchased,
any_value(v.value_segment) AS value_segment,
any_value(v.recency_days) AS recency_days,
any_value(v.recency_score) AS recency_score,
any_value(v.frequency_score) AS frequency_score,
any_value(v.monetary_score) AS monetary_score,
any_value(v.rfm_total_score) AS rfm_total_score,
any_value(o.total_orders) AS total_orders,
any_value(o.total_quantity) AS total_quantity,
any_value(o.total_spent) AS total_spent,
any_value(o.avg_unit_price) AS avg_unit_price,
any_value(o.avg_items_per_order) AS avg_items_per_order,
-- Derived metrics
any_value(o.total_spent) AS lifetime_value,
CASE
WHEN any_value(o.total_orders) > 1 
THEN DATEDIFF(day, any_value(b.first_purchase), any_value(b.last_purchase)) / (any_value(o.total_orders) - 1)
ELSE NULL
END AS avg_days_between_orders
FROM base b
LEFT JOIN cohort c ON b.customerid = c.customerid
LEFT JOIN funnel f ON b.customerid = f.customer_id
LEFT JOIN marketing m ON b.customerid = m.customer_id
LEFT JOIN product pr ON b.customerid = pr.customer_id
LEFT JOIN value v ON b.customerid = v.customerid
LEFT JOIN orders_agg o ON b.customerid = o.customer_id
LEFT JOIN postal p ON b.customerid = p.customer_id
WHERE f.funnel_rank = 1 OR f.funnel_rank IS NULL

