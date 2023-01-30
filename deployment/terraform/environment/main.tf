provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# SendGrid Cloud Function
module "sendgrid_cloud_function" {
  source                     = "./modules/sendgrid-cloud-function"
  region                     = var.region
  source_archive_bucket      = var.sendgrid_cloud_function_source_archive_bucket
  source_archive_object      = var.sendgrid_cloud_function_source_archive_object
  email_from                 = var.email_from
  sendgrid_api_key_secret_id = var.sendgrid_api_key_secret_id
}