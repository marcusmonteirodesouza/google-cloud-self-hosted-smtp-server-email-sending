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

variable "email_server_hostname" {
  type        = string
  description = "A custom hostname for the Email Server VM instance. Must be a fully qualified DNS name and RFC-1035-valid. Valid format is a series of labels 1-63 characters long matching the regular expression [a-z]([-a-z0-9]*[a-z0-9]), concatenated with periods. The entire hostname must not exceed 253 characters."
}

variable "email_password_secret_id" {
  type        = string
  description = "The ID of the secret containing the password used to connect to the SMTP server."
}

variable "smtp_cloud_function_source_archive_bucket" {
  type        = string
  description = "The GCS bucket containing the zip archive which contains the SMTP Cloud Function."
}

variable "smtp_cloud_function_source_archive_object" {
  type        = string
  description = "The source archive object (file) of the SMTP Cloud Function in archive bucket."
}