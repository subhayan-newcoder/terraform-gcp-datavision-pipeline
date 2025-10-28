terraform {
  backend "gcs" {
    bucket = "tf-state-datavision"
    prefix = "terraform/state/prod"
  }
}
