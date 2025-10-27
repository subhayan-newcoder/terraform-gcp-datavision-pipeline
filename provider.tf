terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "terraform-gcp-473706"
  region      = "asia-southeast1"
  zone        = "asia-southeast1-a"
  credentials = "key.json"
}

provider "archive" {
  # Configuration options
}

provider "local" {
  # Configuration options
}
