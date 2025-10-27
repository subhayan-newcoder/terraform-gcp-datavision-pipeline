resource "google_storage_bucket" "bucket1" {
  name                        = "datavision-${var.env}-input-bucket"
  location                    = var.region
  project                     = var.project-id
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.bucket1.id
  topic          = var.cf-pubsub-topic
  payload_format = "JSON_API_V1"
  event_types    = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]
  depends_on     = [google_project_iam_member.gcs-pubsub-publishing]
}

data "google_storage_project_service_account" "gcs_account" {
}

resource "google_project_iam_member" "gcs-pubsub-publishing" {
  project = var.project-id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}
