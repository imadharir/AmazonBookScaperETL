resource "google_compute_router_nat" "composer_nat" {
  name                       = "composer-nat"
  router                     = google_compute_router.composer_router.name
  region                     = google_compute_router.composer_router.region
  nat_ip_allocate_option     = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on = [google_compute_router.composer_router]
}