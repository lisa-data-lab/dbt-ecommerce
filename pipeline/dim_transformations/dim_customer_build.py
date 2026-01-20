import dlt
from pyspark.sql.functions import col

@dlt.table(
    name="silver_dev.customers.dim_customer",
    comment="Dimension table of customers with unique customer_id from silver demographics table"
)
def dim_customer():
    
    demo_df = dlt.read("silver_dev.customers.silver_customers_demographics")

    # Select only needed columns
    return demo_df.select(
        col("customer_id"),
        col("first_name"),
        col("last_name"),
        col("email_hash"),
        col("phone"),
        col("address_line1"),
        col("city"),
        col("state_province"),
        col("postal_code"),
        col("country")
    )

