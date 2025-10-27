import base64
import os
import json
from google.cloud import storage, bigquery


def pubsub_handler(event, context):
    bucket_name = event["attributes"]["bucketId"]
    file_name = event["attributes"]["objectId"]
    print(f"Processing file: gs://{bucket_name}/{file_name}")

    # Environment variables (set in Terraform or manually)
    dataset_id = os.environ.get("BQ_DATASET")
    table_id = os.environ.get("BQ_TABLE")

    if not dataset_id or not table_id:
        raise ValueError("Environment variables BQ_DATASET and BQ_TABLE are required")

    # Initialize clients
    storage_client = storage.Client()
    bq_client = bigquery.Client()

    # Download the file content
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    data_bytes = blob.download_as_bytes()
    json_data = json.loads(data_bytes)

    # Convert single JSON object to list if necessary
    if isinstance(json_data, dict):
        json_data = [json_data]

    # Define destination table
    table_ref = f"{bq_client.project}.{dataset_id}.{table_id}"

    # Configure load job
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        autodetect=True,
        write_disposition="WRITE_APPEND",
    )

    # Upload data
    job = bq_client.load_table_from_json(json_data, table_ref, job_config=job_config)
    job.result()  # Wait for job to complete

    print(f"Loaded {len(json_data)} rows into {table_ref}")
