provider "google" {
  project = "amazon-books-etl"
  region  = var.region
}

data "google_project" "project" {
}

output "project_number" {
  value = data.google_project.project.number
}







