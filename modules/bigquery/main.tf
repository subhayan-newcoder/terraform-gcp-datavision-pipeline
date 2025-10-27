resource "google_bigquery_dataset" "bq-dataset" {
  dataset_id = "datavision_${var.env}_dataset"
  access {
    iam_member = "allUsers"
    role       = "roles/bigquery.dataViewer"
  }
  access {
    user_by_email = var.cf-sa
    role          = "roles/bigquery.dataEditor"
  }
  access {
    role          = "OWNER"
    user_by_email = "terraform-gcp@terraform-gcp-473706.iam.gserviceaccount.com"
  }
}

data "local_file" "schema-file" {
  filename = "${path.cwd}/schema.json"
}

locals {
  data = data.local_file.schema-file.content
}

resource "google_bigquery_table" "bq-table" {
  dataset_id          = google_bigquery_dataset.bq-dataset.dataset_id
  table_id            = "data_from_cf_tf"
  schema              = local.data
  deletion_protection = false
}
