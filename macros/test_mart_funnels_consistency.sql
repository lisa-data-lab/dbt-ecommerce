{% test mart_funnels (model) %}

WITH invalid_rows AS (
    SELECT *
    FROM {{ model }}
    WHERE 
        campaign_id IS NULL
        OR channel IS NULL

        OR rate_awareness_to_consideration < 0
        OR rate_awareness_to_consideration > 1
        OR rate_consideration_to_conversion < 0
        OR rate_consideration_to_conversion > 1
        OR rate_overall_conversion < 0
        OR rate_overall_conversion > 1

        OR avg_days_to_convert < 0
        OR median_days_to_convert < 0

        OR conversion_users > consideration_users
        OR consideration_users > awareness_users
)

SELECT *
FROM invalid_rows

{% endtest %}
