import dlt
from pyspark.sql.functions import col, round, when, current_timestamp

@dlt.table(
    name="silver_dev.orders.invoice_items",
    comment="Cleaned and validated invoice line items for Silver layer",
    table_properties={"quality": "silver"}
)

@dlt.expect_or_drop("non_null_invoice_no", "invoice_no IS NOT NULL")
@dlt.expect_or_drop("non_null_stockcode", "stockcode IS NOT NULL")

@dlt.expect_or_drop("positive_quantity", "quantity > 0")
@dlt.expect_or_drop("positive_unitprice", "unitprice > 0")

@dlt.expect_or_drop("non_null_invoicedate", "invoicedate IS NOT NULL")
@dlt.expect("invoicedate_not_future", "invoicedate <= current_timestamp()")

def silver_invoice_items():
    bronze_df = spark.readStream.table("bronze_dev.ecommerce.ecommerce_invoice_items")

    cleaned = (
        bronze_df
        .withColumn("quantity", col("quantity").cast("int"))
        .withColumn("unitprice", col("unitprice").cast("double"))
        .withColumn(
            "line_total",
            when(col("line_total").isNotNull(), col("line_total"))
            .otherwise(round(col("quantity") * col("unitprice"), 2))
        )
        .withColumn("invoicedate", col("invoicedate").cast("timestamp"))
        .select(
            "invoice_no",
            "stockcode",
            "description",
            "quantity",
            "unitprice",
            "invoicedate",
            "line_total"
        )
    )

    return cleaned
