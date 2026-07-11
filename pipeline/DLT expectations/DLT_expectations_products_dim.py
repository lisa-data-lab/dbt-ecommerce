import dlt
from pyspark.sql.functions import col, to_timestamp

@dlt.table(
    name="silver_dev.products.products_dim",
    comment="Dimension table capturing product metadata and statistics",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("non_null_stockcode", "stockcode IS NOT NULL")
@dlt.expect_or_drop("non_null_description", "description IS NOT NULL")
@dlt.expect_or_drop("non_negative_avg_unit_price", "avg_unit_price >= 0")
@dlt.expect_or_drop("non_negative_total_qty", "total_qty >= 0")
@dlt.expect_or_drop("first_seen_before_last_seen", "first_seen <= last_seen")
def products_dim():
    # Read from Bronze layer (adjust the table name as needed)
    bronze_df = spark.readStream.table("bronze_dev.ecommerce.ecommerce_products_dim")

    cleaned = (
        bronze_df
        .withColumn("first_seen", to_timestamp(col("first_seen"), "M/d/yyyy H:mm"))
        .withColumn("last_seen", to_timestamp(col("last_seen"), "M/d/yyyy H:mm"))
      
        .dropDuplicates(["stockcode"])
        .select(
            "stockcode",
            "description",
            "avg_unit_price",
            "first_seen",
            "last_seen",
            "total_qty"
        )
    )

    return cleaned
