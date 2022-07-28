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