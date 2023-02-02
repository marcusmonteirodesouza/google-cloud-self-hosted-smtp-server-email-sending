resource "google_compute_network" "public_network" {
  name                    = "public-network"
  auto_create_subnetworks = true
}