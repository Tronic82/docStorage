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