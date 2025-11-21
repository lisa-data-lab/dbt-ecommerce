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
days_to_convert
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
b.customerid,
b.country,
p.postal_code,
c.cohort_month,
b.first_purchase,
b.last_purchase,
b.avg_order_value,
b.days_since_last_purchase,
b.revenue_per_day,
f.campaign_id,
f.channel AS funnel_channel,
f.first_awareness_ts,
f.first_consideration_ts,
f.first_conversion_ts,
f.is_converted,
f.days_to_convert,
m.first_campaign_id,
m.channel_first_touch,
m.acquisition_cost,
pr.favorite_product_id,
pr.favorite_product_description,
pr.total_products_purchased,
v.value_segment,
v.recency_days,
v.recency_score,
v.frequency_score,
v.monetary_score,
v.rfm_total_score,
o.total_orders,
o.total_quantity,
o.total_spent,
o.avg_unit_price,
o.avg_items_per_order,
-- Derived metrics
o.total_spent AS lifetime_value,
CASE
WHEN o.total_orders > 1 THEN DATEDIFF(day, b.first_purchase, b.last_purchase) / (o.total_orders - 1)
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
