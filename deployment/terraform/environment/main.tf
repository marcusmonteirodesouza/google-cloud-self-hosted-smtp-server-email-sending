provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "networks" {
  source = "./modules/networks"
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

# SMTP Cloud Function
resource "google_compute_address" "email_server" {
  name = "email-server-address"
}

module "smtp_cloud_function" {
  source                    = "./modules/smtp-cloud-function"
  region                    = var.region
  source_archive_bucket     = var.sendgrid_cloud_function_source_archive_bucket
  source_archive_object     = var.sendgrid_cloud_function_source_archive_object
  email_from                = var.email_from
  email_server_hostname     = var.email_server_hostname
  email_password_secret_id  = var.email_password_secret_id
  email_server_machine_type = "e2-standard-2"
  email_server_ip_address   = google_compute_address.email_server.address
  public_network_name       = module.networks.public_network_name
}