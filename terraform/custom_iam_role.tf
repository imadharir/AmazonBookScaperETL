resource "google_project_iam_custom_role" "my-custom-role" {
  role_id     = "myCustomRole"
  title       = "Private Services Connection Role"
  permissions = ["compute.addresses.create", "compute.addresses.list", "compute.networks.list", "servicenetworking.services.addPeering"]
  depends_on = [google_composer_environment.composer_env]
}

resource "google_project_iam_binding" "my-custom-role-binding" {
  project = var.project_id
  role = "projects/${data.google_project.project.project_id}/roles/${google_project_iam_custom_role.my-custom-role.role_id}"
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_project_iam_custom_role.my-custom-role]
}

resource "google_project_iam_binding" "sqladmin-role-binding" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_composer_environment.composer_env]
}

resource "google_project_iam_binding" "sqlclient-role-binding" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_composer_environment.composer_env]
}

resource "google_project_iam_binding" "compute-network-admin-role-binding" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_composer_environment.composer_env]
}

resource "google_project_iam_binding" "service-usage-admin-role-binding" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_composer_environment.composer_env]
}

resource "google_project_iam_binding" "editor-role-binding" {
  project = var.project_id
  role    = "roles/editor"
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
  depends_on = [google_composer_environment.composer_env]
}