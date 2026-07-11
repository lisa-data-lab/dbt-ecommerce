import dlt
from pyspark.sql.functions import col

@dlt.table(
    name="silver_dev.customers.silver_customers_demographics",
    comment="Cleaned customer demographics for Silver layer",
    table_properties={"quality": "silver"}
)

@dlt.expect_or_drop("non_null_customer_id", "customer_id IS NOT NULL")
@dlt.expect_or_drop("non_null_first_name", "first_name IS NOT NULL")
@dlt.expect_or_drop("non_null_last_name", "last_name IS NOT NULL")
@dlt.expect_or_drop("non_null_address", "address_line1 IS NOT NULL")
@dlt.expect_or_drop("non_null_city", "city IS NOT NULL")
@dlt.expect_or_drop("non_null_state_province", "state_province IS NOT NULL")
@dlt.expect_or_drop("non_null_postal_code", "postal_code IS NOT NULL")
@dlt.expect_or_drop("non_null_country", "country IS NOT NULL")
@dlt.expect_or_drop("valid_postal_code", "postal_code RLIKE '^[0-9]{5}(-[0-9]{4})?$'")
@dlt.expect_or_drop("valid_phone", "phone IS NULL OR phone RLIKE '^\\+?[0-9\\- ]{7,15}$'")
@dlt.expect_or_drop("valid_email_hash", "email_hash RLIKE '^[a-fA-F0-9]{32,64}$'")
def silver_customers_demographics():
    
    bronze_stream = dlt.read_stream("bronze_dev.ecommerce.ecommerce_customers_demographics")
    
    return bronze_stream.select(
        "customer_id",
        "first_name",
        "last_name",
        "address_line1",
        "city",
        "state_province",
        "postal_code",
        "country",
        "phone",
        "email_hash"
    )


