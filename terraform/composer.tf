resource "google_composer_environment" "composer_env" {
  name   = "my-composer-environment"
  region = var.region

  config {
    software_config {
      image_version = "composer-2-airflow-2"
      pypi_packages = {
        beautifulsoup4 = ""
      }
    }

    node_config {
      network = google_compute_network.composer_vpc.self_link
      subnetwork = google_compute_subnetwork.composer_subnet.self_link
    } 

    private_environment_config {
      enable_private_endpoint = true
      master_ipv4_cidr_block     = "10.0.16.0/28"  
      cloud_sql_ipv4_cidr_block  = "10.0.32.0/24"  
    }
  } 
  depends_on = [
    google_compute_network.composer_vpc,
    google_compute_subnetwork.composer_subnet,
    google_compute_router.composer_router,
    google_compute_router_nat.composer_nat,
    google_service_networking_connection.private_vpc_connection
  ] 
}