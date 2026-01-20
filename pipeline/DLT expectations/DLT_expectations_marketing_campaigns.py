import dlt
from pyspark.sql.functions import col, to_timestamp, current_timestamp

@dlt.table(
    name="silver_dev.marketing.marketing_campaigns",
    comment="Dimension table capturing marketing campaign metadata",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("non_null_campaign_id", "campaign_id IS NOT NULL")
@dlt.expect_or_drop("non_null_channel", "channel IS NOT NULL")
@dlt.expect_or_drop("non_null_start_dt", "start_dt IS NOT NULL")
@dlt.expect_or_drop("non_null_end_dt", "end_dt IS NOT NULL")
@dlt.expect_or_drop("non_null_objective", "objective IS NOT NULL")
@dlt.expect_or_drop("non_null_budget", "budget IS NOT NULL")
@dlt.expect_or_drop("valid_dates", "start_dt <= end_dt")
def marketing_campaigns():
    
    bronze_df = spark.readStream.table("bronze_dev.ecommerce.ecommerce_marketing_campaigns")

    cleaned = (
        bronze_df
        .withColumn("start_dt", to_timestamp(col("start_dt"), "M/d/yyyy H:mm"))
        .withColumn("end_dt", to_timestamp(col("end_dt"), "M/d/yyyy H:mm"))
      
        .dropDuplicates(["campaign_id"])
        .select(
            "campaign_id",
            "channel",
            "start_dt",
            "end_dt",
            "objective",
            "budget"
        )
    )

    return cleaned
