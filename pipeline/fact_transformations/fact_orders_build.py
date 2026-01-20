import dlt
from pyspark.sql.functions import col, sum as _sum, countDistinct, avg, lit, min as _min

@dlt.table(
    name="silver_dev.orders.fact_orders",
    comment="Fact table at order/invoice level aggregated from fact_order_items"
)
def fact_orders():
    items_df = dlt.read("silver_dev.orders.fact_order_items")

    fact_df = (
        items_df.groupBy("order_id")
        .agg(
            _min("order_date").alias("order_date"),      # earliest date in case of multiple lines
            _sum("quantity").alias("total_quantity"),
            _sum("line_total").alias("total_amount"),
            countDistinct("product_id").alias("item_count"),
            avg("unit_price").alias("avg_unit_price")
        )
        .withColumn("currency_code", lit("USD"))  # static currency
    )

    return fact_df

