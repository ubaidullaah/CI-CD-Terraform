import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql.functions import current_timestamp, lit

args = getResolvedOptions(sys.argv, ["RAW_PATH", "PROCESSED_PATH"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

raw_path = args["RAW_PATH"]
df = spark.read.option("header", "true").csv(raw_path)

df = df.withColumn("ingested_at", current_timestamp()).withColumn("source", lit("glue_etl_demo"))

processed_path = args["PROCESSED_PATH"]
df.write.mode("overwrite").parquet(processed_path)

print("ETL job completed successfully!")
