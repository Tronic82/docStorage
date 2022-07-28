# create a vpc network
resource "google_compute_network" "vpc_network" {
  project                         = var.project
  name                            = var.network_name
  auto_create_subnetworks         = true
  delete_default_routes_on_create = false
}

output "vpc_name" {
  value = google_compute_network.vpc_network.name
}