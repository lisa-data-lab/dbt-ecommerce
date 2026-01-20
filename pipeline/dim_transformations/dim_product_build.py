from pyspark import pipelines as dp
from pyspark.sql.functions import col, expr

dp.create_streaming_table(
    name="silver_dev.products.dim_product",
   comment="Slowly Changing Dimension Type 2 for products"
)

# 2️⃣ Create automatic CDC flow with SCD2
dp.create_auto_cdc_flow(
    target="silver_dev.products.dim_product",
    source="silver_dev.products.products_dim",
    keys=["stockcode"],               # natural key for the product
    sequence_by=col("last_seen"),     # column that orders changes
    ignore_null_updates=False,        # updates even if some columns are null
    apply_as_deletes=expr("false"),   # handle deletes if needed
    except_column_list=[],            # columns to ignore for SCD2
    stored_as_scd_type="2"           # enable SCD Type 2
)
