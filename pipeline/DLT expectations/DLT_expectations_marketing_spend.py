import dlt
from pyspark.sql.functions import col, to_date

@dlt.table(
    name="silver_dev.marketing.marketing_spend",
    comment="Fact table capturing daily marketing spend and performance metrics",
    table_properties={"quality": "silver"}
)
@dlt.expect_or_drop("non_null_campaign_id", "campaign_id IS NOT NULL")
@dlt.expect_or_drop("non_null_day", "day IS NOT NULL")
@dlt.expect_or_drop("non_negative_impressions", "impressions >= 0")
@dlt.expect_or_drop("non_negative_clicks", "clicks >= 0")
@dlt.expect_or_drop("non_negative_spend", "spend >= 0")
def marketing_spend():
   
    bronze_df = spark.readStream.table("bronze_dev.ecommerce.ecommerce_marketing_spend")

    cleaned = (
        bronze_df
        .withColumn("day", to_date(col("day"), "M/d/yyyy"))
        
        .dropDuplicates(["campaign_id", "day"])
        .select(
            "campaign_id",
            "day",
            "impressions",
            "clicks",
            "spend"
        )
    )

    return cleaned
