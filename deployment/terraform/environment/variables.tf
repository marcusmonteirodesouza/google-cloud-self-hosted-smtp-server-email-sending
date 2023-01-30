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

variable "sendgrid_api_key" {
  type        = string
  description = "The SendGrid API key"
  sensitive   = true
}