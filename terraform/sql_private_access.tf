resource "google_compute_firewall" "allow_sql_private_access" {
  name    = "allow-sql-private-access"
  network = google_compute_network.composer_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["10.0.0.0/8"] 
  direction     = "INGRESS"
  depends_on = [
    google_compute_subnetwork.composer_subnet,
    google_sql_database_instance.postgres_pvp_instance_name
  ]
}
