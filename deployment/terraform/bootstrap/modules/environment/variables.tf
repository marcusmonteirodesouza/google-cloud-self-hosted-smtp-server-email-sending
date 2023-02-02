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

variable "email_server_hostname" {
  type        = string
  description = "A custom hostname for the Email Server VM instance. Must be a fully qualified DNS name and RFC-1035-valid. Valid format is a series of labels 1-63 characters long matching the regular expression [a-z]([-a-z0-9]*[a-z0-9]), concatenated with periods. The entire hostname must not exceed 253 characters."
}