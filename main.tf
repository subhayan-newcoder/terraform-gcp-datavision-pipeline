module "cloud-function" {
  source          = "./modules/cloud_function"
  depends_on      = [module.storage]
  cf-pubsub-topic = module.pubsub.cf-pubsub-topic-id
  env             = var.env
  project-id      = var.project-id
  region          = var.region
}

module "storage" {
  source          = "./modules/storage"
  cf-pubsub-topic = module.pubsub.cf-pubsub-topic-id
  depends_on      = [module.pubsub]
  env             = var.env
  project-id      = var.project-id
  region          = var.region
}

module "pubsub" {
  source     = "./modules/pubsub"
  env        = var.env
  project-id = var.project-id
  region     = var.region
}

module "bigquery" {
  source     = "./modules/bigquery"
  cf-sa      = module.cloud-function.cloud-function-sa
  depends_on = [module.cloud-function]
  env        = var.env
  project-id = var.project-id
  region     = var.region
}

resource "google_storage_bucket_object" "data" {
  bucket     = module.storage.input-bucket-name
  name       = "data.json"
  source     = "${path.cwd}/data.json"
  depends_on = [module.bigquery]
}
