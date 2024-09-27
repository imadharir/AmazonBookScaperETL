resource "google_compute_network" "composer_vpc" {
  name                    = "composer-private-vpc"
  auto_create_subnetworks = false
}
