import dlt
from pyspark.sql.functions import col, to_date, lit

@dlt.table(
    name="silver_dev.orders.fact_order_items",
    comment="Fact table at line-item level with static currency column"
)
def fact_order_items():
    items_df = dlt.read("silver_dev.orders.invoice_items")

    fact_df = items_df.select(
        col("invoice_no").alias("order_id"),
        col("stockcode").alias("product_id"),   
        col("quantity"),
        col("unitprice").alias("unit_price"),
        (col("quantity") * col("unitprice")).alias("line_total"),
        to_date(col("invoicedate")).alias("order_date")
    ).withColumn("currency_code", lit("USD"))  
    return fact_df

