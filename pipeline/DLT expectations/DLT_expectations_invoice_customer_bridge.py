import dlt
from pyspark.sql.functions import col

@dlt.table(
    name="silver_dev.orders.invoice_customer_bridge",
    comment="Cleaned bridge table linking invoices to customers for Silver layer",
    table_properties={"quality": "silver"}
   )

@dlt.expect_or_drop("non_null_invoice_no", "invoice_no IS NOT NULL")
@dlt.expect_or_drop("non_null_customer_id", "customer_id IS NOT NULL")

def silver_invoice_customer_bridge():
    bronze_stream = dlt.read_stream("bronze_dev.ecommerce.ecommerce_invoice_customer_bridge")
   
    return bronze_stream.select(
        "invoice_no",
        "customer_id"
    )
