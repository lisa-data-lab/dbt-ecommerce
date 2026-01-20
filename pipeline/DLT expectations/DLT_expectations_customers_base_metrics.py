import dlt
from pyspark.sql.functions import col

@dlt.table(
    name="silver_dev.customers.silver_customers_base_metrics",
    comment="Cleaned customer base metrics for Silver layer",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("non_null_customerid", "customerid IS NOT NULL")
@dlt.expect_or_drop("non_null_first_purchase", "first_purchase IS NOT NULL")
@dlt.expect_or_drop("non_null_last_purchase", "last_purchase IS NOT NULL")
@dlt.expect_or_drop("last_after_first", "last_purchase >= first_purchase")
@dlt.expect_or_drop("non_negative_orders", "orders >= 0")
@dlt.expect_or_drop("non_negative_qty", "qty >= 0")
@dlt.expect_or_drop("non_negative_revenue", "gross_revenue >= 0")
def silver_customers_base_metrics():
   
    bronze_stream = dlt.read_stream("bronze_dev.ecommerce.ecommerce_customers_base_metrics")
    
    return bronze_stream.select(
        "customerid",
        "country",
        "first_purchase",
        "last_purchase",
        "orders",
        "qty",
        "gross_revenue"
    )
