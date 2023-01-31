variable "region" {
  type        = string
  description = "The default GCP region for the created resources."
}

variable "source_archive_bucket" {
  type        = string
  description = "The GCS bucket containing the zip archive which contains the function."
}

variable "source_archive_object" {
  type        = string
  description = "The source archive object (file) in archive bucket."
}

variable "email_from" {
  type        = string
  description = "The email address the system will send emails from."
}

variable "email_server_hostname" {
  type        = string
  description = "A custom hostname for the Email Server VM instance. Must be a fully qualified DNS name and RFC-1035-valid. Valid format is a series of labels 1-63 characters long matching the regular expression [a-z]([-a-z0-9]*[a-z0-9]), concatenated with periods. The entire hostname must not exceed 253 characters."
}


variable "email_password_secret_id" {
  type        = string
  description = "The ID of the secret containing the password used to connect to the SMTP server."
}

variable "email_server_machine_type" {
  type        = string
  description = "The Email Server VM machine type."
}

variable "email_server_ip_address" {
  type        = string
  description = "The IP address to be assigned to the Email Server."
}

variable "public_network_name" {
  type        = string
  description = "The public network name in which resources will be created."
}