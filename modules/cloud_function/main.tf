resource "google_storage_bucket" "bucket2" {
  name                        = "data-vision-${var.env}-bucket-for-cf-from-tf"
  location                    = "asia-southeast1"
  uniform_bucket_level_access = true
}

resource "archive_file" "init-zip" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/function.zip"

}

resource "google_storage_bucket_object" "code" {
  name       = "${var.env}/${archive_file.init-zip.output_md5}-function.zip"
  bucket     = google_storage_bucket.bucket2.name
  source     = archive_file.init-zip.output_path
  depends_on = [google_storage_bucket.bucket2, archive_file.init-zip]
}

resource "google_cloudfunctions2_function" "cf1" {
  name     = "datavision-${var.env}-pub-sub-triggered-cf"
  location = var.region
  build_config {
    runtime     = "python312"
    entry_point = "pubsub_handler"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket2.id
        object = google_storage_bucket_object.code.name
      }
    }
  }
  service_config {
    timeout_seconds       = 300
    available_memory      = "512M"
    service_account_email = google_service_account.cf-service_account.email
    ingress_settings      = "ALLOW_ALL"
    environment_variables = {
      BQ_DATASET = "datavision_${var.env}_dataset"
      BQ_TABLE   = "data_from_cf_tf"
    }
  }
  event_trigger {
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = var.cf-pubsub-topic
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    trigger_region = var.region
  }
}

# resource "google_cloud_run_service_iam_member" "invoker" {
#   service  = google_cloudfunctions2_function.cf1.id
#   location = var.region
#   project  = var.project-id
#   role     = "roles/run.invoker"
#   member   = "serviceAccount:${var.cf-sa}"
# }


resource "google_cloudfunctions2_function_iam_binding" "member" {
  project        = google_cloudfunctions2_function.cf1.project
  location       = google_cloudfunctions2_function.cf1.location
  cloud_function = google_cloudfunctions2_function.cf1.name
  role           = "roles/cloudfunctions.invoker"
  members        = ["allUsers"]
}

resource "google_service_account" "cf-service_account" {
  account_id                   = "datavision-${var.env}-cf-sa-id"
  display_name                 = "datavision-${var.env}-cf-sa-id"
  create_ignore_already_exists = true
}

resource "google_service_account_iam_member" "cf_act_as_permission" {
  service_account_id = google_service_account.cf-service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:terraform-gcp@terraform-gcp-473706.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cf_act_as_permission-2" {
  service_account_id = "projects/-/serviceAccounts/934799395477-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:terraform-gcp@terraform-gcp-473706.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "cf_sa_storage_viewer" {
  project = var.project-id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cf-service_account.email}"
}

resource "google_project_iam_member" "cf_sa_bigquery_admin" {
  project = var.project-id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.cf-service_account.email}"
}

data "google_project" "project" {
}

resource "google_cloud_run_service_iam_member" "pub_sub_invoker" {
  location   = var.region
  service    = google_cloudfunctions2_function.cf1.name
  role       = "roles/run.invoker"
  member     = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  depends_on = [google_cloudfunctions2_function.cf1]
}

resource "google_cloud_run_service_iam_member" "eventarc_invoker" {
  location   = var.region
  service    = google_cloudfunctions2_function.cf1.name
  role       = "roles/run.invoker"
  member     = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
  depends_on = [google_cloudfunctions2_function.cf1]
}
