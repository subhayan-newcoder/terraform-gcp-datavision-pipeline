resource "google_pubsub_topic" "topic1" {
  name                       = "datavision-${var.env}-gcs-data-input-topic"
  message_retention_duration = "86600s"
}
