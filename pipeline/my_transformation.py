from dlt import *
from pyspark.sql.functions import *

catalog = "bronze_dev"
schema = dbName = db = "ecommerce"
volume_name = "volumes"
path = f"/Volumes/{catalog}/{schema}/{volume_name}/raw_data"
file_format = 'parquet'

target_table_customers_base_metrics = "ecommerce_customers_base_metrics"

dlt.create_streaming_table(target_table_customers_base_metrics, comment="New customers base metrics data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_customers_base_metrics,
    name = "ecommerce_bronze_ingest_flow"
)
def ecommerce_customers_base_metrics_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/customers_base_metrics")
    )

target_table_customers_demographics = "ecommerce_customers_demographics"

dlt.create_streaming_table(target_table_customers_demographics, comment="New customers demographics data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_customers_demographics,
    name = "ecommerce_customers_demographics_ingest_flow"
)
def ecommerce_customers_demographics_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/customers_demographics")
    )

target_table_event_triggers = "ecommerce_event_triggers"

dlt.create_streaming_table(target_table_event_triggers, comment="New event triggers data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_event_triggers,
    name = "ecommerce_event_triggers_ingest_flow"
)

def ecommerce_event_triggers_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/event_triggers")
    )

target_table_invoice_customer_bridge = "ecommerce_invoice_customer_bridge"

dlt.create_streaming_table(target_table_invoice_customer_bridge, comment="New invoice customer bridge data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_invoice_customer_bridge,
    name = "ecommerce_invoice_customer_bridge_ingest_flow"
)
def ecommerce_invoice_customer_bridge_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/invoice_customer_bridge")
    )

target_table_invoice_items = "ecommerce_invoice_items"

dlt.create_streaming_table(target_table_invoice_items, comment="New table  invoice items data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_invoice_items,
    name = "ecommerce_invoice_items_ingest_flow"
)
def ecommerce_invoice_items_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/invoice_items")
    )

target_table_journey_events = "ecommerce_journey_events"

dlt.create_streaming_table(target_table_journey_events, comment="New journey events data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_journey_events,
    name = "ecommerce_journey_events_ingest_flow"
)
def ecommerce_journey_events_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/journey_events")
    )

target_table_marketing_campaigns = "ecommerce_marketing_campaigns"

dlt.create_streaming_table(target_table_marketing_campaigns, comment="New marketing campaigns data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_marketing_campaigns,
    name = "ecommerce_marketing_campaigns_ingest_flow"
)
def ecommerce_marketing_campaigns_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/marketing_campaigns")
    )

target_table_marketing_spend = "ecommerce_marketing_spend"

dlt.create_streaming_table(target_table_marketing_spend, comment="New marketing spend data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_marketing_spend,
    name = "ecommerce_marketing_spend_ingest_flow"
)
def ecommerce_marketing_spend_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/marketing_spend")
    )

target_table_products_dim = "ecommerce_products_dim"

dlt.create_streaming_table(target_table_products_dim, comment="New products dimension data incrementally ingested from cloud object storage landing zone")

@append_flow(
    target = target_table_products_dim,
    name = "ecommerce_products_dim_ingest_flow"
)
def ecommerce_products_dim_ingest_flow():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", file_format)
        .option("cloudFiles.inferColumnTypes", "true")
        .load(f"{path}/products_dim")
    )
