output "input-bucket-name" {
  value       = google_storage_bucket.bucket1.id
  description = "this is the input bucket name"
}

output "input-bucket-url" {
  value       = google_storage_bucket.bucket1.url
  description = "this is the input bucket url"
}
