locals {
  cloudbuild_sa_email = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  cloudbuild_sa_roles = [
    "roles/cloudfunctions.admin",
    "roles/eventarc.admin",
    "roles/iam.serviceAccountUser",
  ]

  compute_sa_email = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  compute_sa_roles = [
  ]

  cloud_function_buckets = {
    "sendgrid" : "sendgrid-cloud-function-${random_id.random.hex}",
  }

  sendgrid_api_key_secret_version = "${google_secret_manager_secret.sendgrid_api_key.id}/versions/${google_secret_manager_secret_version.sendgrid_api_key.version}"
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_sourcerepo_repository" "repo" {
  project = var.project_id
  name    = var.sourcerepo_name
}

resource "random_id" "random" {
  byte_length = 4
}

# Push to branch
resource "google_cloudbuild_trigger" "push_to_branch_deployment" {
  project     = var.project_id
  name        = "push-to-branch-deployment"
  description = "Deployment Pipeline - Cloud Source Repository Trigger ${data.google_sourcerepo_repository.repo.name} push to ${var.branch_name}"

  trigger_template {
    repo_name   = data.google_sourcerepo_repository.repo.name
    branch_name = var.branch_name
  }

  filename = "deployment/google-cloud/cloudbuild/cloudbuild.yaml"

  substitutions = {
    _TFSTATE_BUCKET                                = var.tfstate_bucket
    _REGION                                        = var.region
    _SENDGRID_CLOUD_FUNCTION_SOURCE_ARCHIVE_BUCKET = local.cloud_function_buckets["sendgrid"]
    _SENDGRID_API_KEY_SECRET_VERSION               = local.sendgrid_api_key_secret_version
  }
}

# Cloud Build Service Account roles and permissions
resource "google_project_iam_member" "cloudbuild_sa" {
  for_each = toset(local.cloudbuild_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${local.cloudbuild_sa_email}"
}

# Default Compute Service Account roles and permissions
resource "google_project_iam_member" "compute_sa" {
  for_each = toset(local.compute_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${local.compute_sa_email}"
}

# Cloud Function Buckets
resource "google_storage_bucket" "cloud_functions" {
  for_each      = local.cloud_function_buckets
  project       = var.project_id
  name          = each.value
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "cloudbuild_sa_cloud_functions_storage_admin" {
  for_each = local.cloud_function_buckets
  bucket   = each.value
  role     = "roles/storage.admin"
  member   = "serviceAccount:${local.cloudbuild_sa_email}"

  depends_on = [
    google_storage_bucket.cloud_functions
  ]
}

# SendGrid 
resource "google_secret_manager_secret" "sendgrid_api_key" {
  project   = var.project_id
  secret_id = "sendgrid-api-key"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "sendgrid_api_key" {
  secret      = google_secret_manager_secret.sendgrid_api_key.id
  secret_data = var.sendgrid_api_key
}

resource "google_secret_manager_secret_iam_member" "sendgrid_api_key_cloudbuild_sa" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.sendgrid_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.cloudbuild_sa_email}"
}

resource "google_secret_manager_secret_iam_member" "sendgrid_api_key_compute_sa" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.sendgrid_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.compute_sa_email}"
}

# Cloud Build Community Builders
resource "null_resource" "submit_community_builders" {
  provisioner "local-exec" {
    command     = "./submit-community-builders.sh ${var.project_id}"
    working_dir = "${path.module}/scripts"
  }
}