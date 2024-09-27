resource "google_compute_subnetwork" "composer_subnet" {
  name          = "composer-private-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.composer_vpc.self_link
  private_ip_google_access = true
}