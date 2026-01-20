import dlt
from pyspark.sql.functions import col, to_date, sequence, explode, date_format, year, month, dayofmonth, dayofweek, weekofyear, quarter, lit, expr

@dlt.table(
    name="silver_dev.shared.dim_date",
    comment="Date dimension table for analytics and time-based joins"
)
def dim_date():
    start_date = "2020-01-01"
    end_date = "2030-12-31"

 
    date_seq_df = (
        spark.createDataFrame([(start_date, end_date)], ["start_date", "end_date"])
        .withColumn("start_date", to_date(col("start_date")))
        .withColumn("end_date", to_date(col("end_date")))
        .withColumn("date_key", explode(sequence(col("start_date"), col("end_date"), expr("INTERVAL 1 DAY"))))
        .select("date_key")
    )

    # Add useful date attributes
    enriched_df = (
        date_seq_df
        .withColumn("year", year("date_key"))
        .withColumn("quarter", quarter("date_key"))
        .withColumn("month", month("date_key"))
        .withColumn("day", dayofmonth("date_key"))
        .withColumn("day_of_week", dayofweek("date_key"))
        .withColumn("week_of_year", weekofyear("date_key"))
        .withColumn("month_name", date_format("date_key", "MMMM"))
        .withColumn("day_name", date_format("date_key", "EEEE"))
    )

    return enriched_df
