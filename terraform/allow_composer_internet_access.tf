resource "google_compute_firewall" "allow_composer_internet_access" {
    name    = "allow-composer-internet-access"
    network = google_compute_network.composer_vpc.name

    direction = "EGRESS"
    priority = 1000

    destination_ranges = ["0.0.0.0/0"]
    
    allow {
        protocol = "tcp"
        ports = ["80", "443"]
    }

    depends_on = [
    google_compute_network.composer_vpc,
    google_compute_subnetwork.composer_subnet
  ]
    
    
}