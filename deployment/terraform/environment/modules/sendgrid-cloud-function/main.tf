locals {
  source_archive_object_with_md5hash = "${trimsuffix(var.source_archive_object, ".zip")}-${data.google_storage_bucket_object.source_archive_object.md5hash}.zip"
}

data "google_project" "project" {
}

data "google_storage_bucket_object" "source_archive_object" {
  name   = var.source_archive_object
  bucket = var.source_archive_bucket
}

resource "google_storage_bucket" "source_archive_bucket_md5hash" {
  name                        = "${var.source_archive_bucket}-md5hash"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "null_resource" "copy_source_archive_object" {
  provisioner "local-exec" {
    command = "gcloud storage cp gs://${var.source_archive_bucket}/${var.source_archive_object} ${google_storage_bucket.source_archive_bucket_md5hash.url}/${local.source_archive_object_with_md5hash} --quiet"
  }
  triggers = {
    md5hash = data.google_storage_bucket_object.source_archive_object.md5hash
  }
}

resource "google_pubsub_topic" "sendgrid" {
  name = "sendgrid"
}

resource "google_cloudfunctions2_function" "sengrid" {
  provider    = google-beta
  name        = "sendgrid"
  location    = var.region
  description = "Sends emails using SendGrid"

  event_trigger {
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.sendgrid.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    trigger_region = var.region
  }

  build_config {
    runtime     = "nodejs16"
    entry_point = "sendEmail"
    source {
      storage_source {
        bucket = google_storage_bucket.source_archive_bucket_md5hash.name
        object = local.source_archive_object_with_md5hash
      }
    }
  }

  service_config {
    max_instance_count = 100
    available_memory   = "256M"
    timeout_seconds    = 60

    environment_variables = {
      EMAIL_FROM = var.email_from
    }

    secret_environment_variables {
      key        = "SENDGRID_API_KEY"
      secret     = var.sendgrid_api_key_secret_id
      project_id = data.google_project.project.number
      version    = "latest"
    }
  }

  depends_on = [
    null_resource.copy_source_archive_object
  ]
}
