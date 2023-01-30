variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default GCP region for the created resources."
}

variable "email_from" {
  type        = string
  description = "The email address the system will send emails from."
}

variable "sendgrid_api_key_secret_id" {
  type        = string
  description = "The SendGrid API key secret id."
}

variable "sendgrid_cloud_function_source_archive_bucket" {
  type        = string
  description = "The GCS bucket containing the zip archive which contains the SendGrid Cloud Function."
}

variable "sendgrid_cloud_function_source_archive_object" {
  type        = string
  description = "The source archive object (file) of the SendGrid Cloud Function in archive bucket."
}