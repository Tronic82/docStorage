terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.75.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.8"
    }
  }
}

provider "google" {
  project = var.project_id
  scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
}

provider "google-beta" {
  alias   = "deploy_provider"
  project = var.project_id
  scopes  = ["https://www.googleapis.com/auth/cloud-platform"]
}

# enable apis
module "apis" {
  source     = "./modules/API"
  services   = var.services
  project_id = var.project_id

}

# create service accounts
module "service_accounts" {
  source           = "./modules/Service_accounts"
  service_accounts = var.service_accounts
  project_id       = var.project_id
}

# create the network
module "vpc_network" {
  source       = "./modules/network"
  project      = var.project_id
  network_name = "docstorage-vpc1"
}

#create the explicit deny firewall rules:
resource "google_compute_firewall" "explicit-deny-egress" {
  depends_on = [
    module.vpc_network
  ]
  name    = "fw-deny-egress"
  network = module.vpc_network.vpc_name

  deny {
    protocol = "all"
  }
  direction          = "EGRESS"
  priority           = 65534
  destination_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "explicit-deny-ingress" {
  depends_on = [
    module.vpc_network
  ]
  name    = "fw-deny-ingress"
  network = module.vpc_network.vpc_name

  deny {
    protocol = "all"
  }
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

#create the allow firewall rules for health check
resource "google_compute_firewall" "allow-health-check" {
  depends_on = [
    module.vpc_network
  ]
  name    = "fw-allow-health-checks-ingress"
  network = module.vpc_network.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["8080", "80"]
  }
  direction     = "INGRESS"
  priority      = 100
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["allow-health-checks"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

#create the allow firewall rules for load balancer
resource "google_compute_firewall" "allow-LB" {
  depends_on = [
    module.vpc_network
  ]
  name    = "fw-allow-network-lb-health-checks"
  network = module.vpc_network.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["8080", "80"]
  }
  direction     = "INGRESS"
  priority      = 100
  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-network-lb-health-checks"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

#create the allow firewall rules for restricted and private endpoint
resource "google_compute_firewall" "allow-restricted-private" {
  depends_on = [
    module.vpc_network
  ]
  name    = "fw-allow-restricted-private-egress"
  network = module.vpc_network.vpc_name

  allow {
    protocol = "all"
  }
  direction          = "EGRESS"
  priority           = 100
  destination_ranges = ["199.36.153.4/30", "199.36.153.8/30"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}


#create proxy only subnet
resource "google_compute_subnetwork" "proxy-only" {
  provider = google-beta
  project  = var.project_id
  name     = "lb-proxy-only-subnetwork"
  # choose this CIDR range as network has auto created subnets so cant overlap with 10.128.0.0/9
  ip_cidr_range = "10.127.0.0/23"
  region        = "europe-west1"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = module.vpc_network.vpc_name
}

#create the allow firewall rules for communication on the proxy subnet
resource "google_compute_firewall" "allow-proxies" {
  depends_on = [
    module.vpc_network
  ]
  name    = "fw-allow-proxies-ingress"
  network = module.vpc_network.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["8080", "80", "443"]
  }
  direction     = "INGRESS"
  priority      = 100
  source_ranges = [google_compute_subnetwork.proxy-only.ip_cidr_range]
  target_tags   = ["allow-proxies"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}