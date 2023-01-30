variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default region in which resources will be created."
}

variable "sourcerepo_name" {
  type        = string
  description = "The Cloud Source Repository name."
}

variable "branch_name" {
  type        = string
  description = "The Cloud Source repository branch name."
}

variable "tfstate_bucket" {
  type        = string
  description = "The GCS bucket to store the project's terraform state."
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