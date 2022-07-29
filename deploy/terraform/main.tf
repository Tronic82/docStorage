terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.30.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.30.0"
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

# this module creates the app components
module "app_component_docstorage" {
  source                  = "./modules/application_component"
  project                 = var.project_id
  debug                   = true
  hc_request_path         = "/"
  app_name                = "docstorage"
  be_balancing_mode       = "UTILIZATION"
  be_protocol             = "HTTP"
  container_name          = "europe-docker.pkg.dev/${var.project_id}/docstorage/docstorage:v0.1.0"
  network                 = "projects/${var.project_id}/global/networks/docstorage-vpc1"
  port                    = 80
  region                  = "europe-west1"
  service_account_name    = "data-accessor"
  network_tags            = ["allow-health-checks", "allow-network-lb-health-checks", "allow-proxies"]
  subnetwork              = "projects/${var.project_id}/regions/europe-west1/subnetworks/docstorage-vpc1"
  zones                   = ["europe-west1-c", "europe-west1-d", "europe-west1-b"]
  environmental_variables = ["GOOGLE_STORAGE_BUCKET=${var.project_id}-storage","GOOGLE_CLOUD_PROJECT=${var.project_id}","ENVIRONMENT=development"]
  # created as one time exercise infrastructure set up
  fr_ip_address = "34.120.164.183"
  hosts         = ["docustores.com", "www.docustores.com"]
  paths         = ["/", "/docs", "/docs/add", "/edit"]
  ip_protocol   = "TCP"
}
