import dlt
from pyspark.sql.functions import col, to_timestamp, current_timestamp

@dlt.table(
    name="silver_dev.events.journey_events",
    comment="Event-level table capturing customer interactions with campaigns",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("non_null_event_id", "event_id IS NOT NULL")
@dlt.expect_or_drop("non_null_customer_id", "customer_id IS NOT NULL")
@dlt.expect_or_drop("non_null_event_type", "event_type IS NOT NULL")
@dlt.expect_or_drop("non_null_ts", "ts IS NOT NULL")
@dlt.expect_or_drop("ts_not_future", "ts <= current_timestamp()")

def silver_journey_events():
    
    bronze_df = spark.readStream.table("bronze_dev.ecommerce.ecommerce_journey_events")

    cleaned = (
        bronze_df
        .withColumn("ts", to_timestamp(col("ts"), "M/d/yyyy H:mm"))
        .dropDuplicates(["event_id"])
        .select(
            "event_id",
            "customer_id",
            "campaign_id",
            "event_type",
            "ts"
        )
    )

    return cleaned
