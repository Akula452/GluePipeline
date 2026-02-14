"""
Example AWS Glue ETL Script with SQL Connection
This script demonstrates how to use Glue with SQL database connections
"""
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col, current_timestamp

# Get job parameters
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'connection_name',
    'source_table',
    'output_path'
])

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

print(f"Starting job: {args['JOB_NAME']}")
print(f"Using connection: {args['connection_name']}")

# Read data from SQL database using Glue connection
print(f"Reading data from table: {args['source_table']}")
datasource = glueContext.create_dynamic_frame.from_options(
    connection_type="postgresql",  # Must match your JDBC URL: postgresql, mysql, sqlserver, oracle, redshift
    connection_options={
        "useConnectionProperties": "true",
        "dbtable": args['source_table'],
        "connectionName": args['connection_name']
    },
    transformation_ctx="datasource"
)

print(f"Records read: {datasource.count()}")

# Convert to DataFrame for transformations
df = datasource.toDF()

# Example transformations
# 1. Add processing timestamp
df_transformed = df.withColumn("processed_at", current_timestamp())

# 2. Filter records (example: only active records)
# df_transformed = df_transformed.filter(col("status") == "active")

# 3. Select specific columns
# df_transformed = df_transformed.select("id", "name", "created_at", "processed_at")

# Convert back to DynamicFrame
dynamic_frame_transformed = DynamicFrame.fromDF(
    df_transformed, 
    glueContext, 
    "transformed_data"
)

print(f"Records after transformation: {dynamic_frame_transformed.count()}")

# Write data to S3 in Parquet format
print(f"Writing data to: {args['output_path']}")
glueContext.write_dynamic_frame.from_options(
    frame=dynamic_frame_transformed,
    connection_type="s3",
    connection_options={
        "path": args['output_path'],
        "partitionKeys": []  # Add partition keys if needed, e.g., ["year", "month"]
    },
    format="parquet",
    transformation_ctx="datasink"
)

print("Job completed successfully")
job.commit()
