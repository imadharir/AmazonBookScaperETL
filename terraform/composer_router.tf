resource "google_compute_router" "composer_router" {
  name    = "composer-router"
  network = google_compute_network.composer_vpc.self_link
  region  = "us-central1"
  depends_on = [google_compute_subnetwork.composer_subnet]
}