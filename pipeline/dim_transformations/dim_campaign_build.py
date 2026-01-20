import dlt
from pyspark.sql.functions import col

@dlt.table(
    name="silver_dev.marketing.dim_campaign",
    comment="Dimension table for marketing campaigns from silver layer"
)
def dim_campaign():
    campaigns_df = dlt.read("silver_dev.marketing.marketing_campaigns")

    # Select and rename columns if needed for clarity
    return campaigns_df.select(
        col("campaign_id"),
        col("channel"),
        col("start_dt"),
        col("end_dt"),
        col("objective"),
        col("budget")
    )
