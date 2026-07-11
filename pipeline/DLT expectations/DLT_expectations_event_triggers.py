import dlt
from pyspark.sql.functions import col, to_timestamp, current_timestamp

@dlt.table(
    name="silver_dev.marketing.event_triggers",
    comment="Table capturing event triggers for customers",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("non_null_customer_id", "customer_id IS NOT NULL")
@dlt.expect_or_drop("non_null_trigger_type", "trigger_type IS NOT NULL")
@dlt.expect_or_drop("non_null_reason", "reason IS NOT NULL")
@dlt.expect_or_drop("valid_from_not_null", "valid_from IS NOT NULL")
@dlt.expect_or_drop("valid_to_not_null", "valid_to IS NOT NULL")
@dlt.expect_or_drop("status_not_null", "status IS NOT NULL")
def event_triggers():
    
    bronze_df = spark.readStream.table("bronze_dev.ecommerce.ecommerce_event_triggers")

    cleaned = (
        bronze_df
        .withColumn("valid_from", to_timestamp(col("valid_from"), "M/d/yyyy H:mm"))
        .withColumn("valid_to", to_timestamp(col("valid_to"), "M/d/yyyy H:mm"))
        # Optional: remove duplicates if there's a primary key like (customer_id, trigger_type, valid_from)
        .dropDuplicates(["customer_id", "trigger_type", "valid_from"])
        .select(
            "customer_id",
            "trigger_type",
            "reason",
            "valid_from",
            "valid_to",
            "status",
            "policy_version"
        )
    )

    return cleaned
