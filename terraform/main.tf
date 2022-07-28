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

#create an address for the load balancer
resource "google_compute_global_address" "external_with_subnet_and_address" {
  name         = "docstorage-global-lb-address"
  address_type = "EXTERNAL"
}


# create KMS key for resource encryption
resource "google_kms_key_ring" "europe-west1-keyring" {
  name     = "europe-west1-keyring"
  location = "europe-west1"
}

resource "google_kms_key_ring" "europe-keyring" {
  name     = "europe-keyring"
  location = "europe"
}

resource "google_kms_crypto_key" "compute" {
  name            = "compute"
  key_ring        = google_kms_key_ring.europe-west1-keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "storage" {
  name            = "storage"
  key_ring        = google_kms_key_ring.europe-keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "artifact-registry" {
  name            = "artifactRegistry1"
  key_ring        = google_kms_key_ring.europe-keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "artifact-registry-europe-west1" {
  name            = "artifactRegistry"
  key_ring        = google_kms_key_ring.europe-west1-keyring.id
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}


#give the artifact registry account access to the kms key
resource "google_kms_crypto_key_iam_member" "crypto_key_artifactRegistry" {
  crypto_key_id = google_kms_crypto_key.artifact-registry.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-297825076535@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}

#give the artifact registry account access to the kms key
resource "google_kms_crypto_key_iam_member" "crypto_key_artifactRegistry-ew-west1" {
  crypto_key_id = google_kms_crypto_key.artifact-registry-europe-west1.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-297825076535@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}

#give the compute account access to the kms key
resource "google_kms_crypto_key_iam_member" "crypto_key_compute" {
  crypto_key_id = google_kms_crypto_key.compute.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-297825076535@compute-system.iam.gserviceaccount.com"
}

#give the storage account access to the kms key
resource "google_kms_crypto_key_iam_member" "crypto_key_storage" {
  crypto_key_id = google_kms_crypto_key.storage.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-297825076535@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "bucket" {
  provider                    = google
  name                        = "${var.project_id}-storage"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
  encryption {
    default_kms_key_name = google_kms_crypto_key.storage.id
  }

  lifecycle_rule {
    condition {
      age = 45
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
}
# assign role bindings
data "google_iam_policy" "admin" {
  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:data-accessor@${var.project_id}.iam.gserviceaccount.com"
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy" {
  provider    = google
  depends_on  = [google_storage_bucket.bucket]
  bucket      = google_storage_bucket.bucket.name
  policy_data = data.google_iam_policy.admin.policy_data
}

resource "google_project_iam_binding" "project-datastore" {
  provider   = google
  project    = var.project_id
  depends_on = [google_storage_bucket.bucket]
  role       = "roles/datastore.user"

  members = [
    "serviceAccount:data-accessor@single-planet-357417.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "project-errorreporting" {
  provider   = google
  project    = var.project_id
  depends_on = [google_storage_bucket.bucket]
  role       = "roles/errorreporting.admin"

  members = [
    "serviceAccount:data-accessor@single-planet-357417.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "project-logwriter" {
  provider   = google
  project    = var.project_id
  depends_on = [google_storage_bucket.bucket]
  role       = "roles/logging.logWriter"

  members = [
    "serviceAccount:data-accessor@single-planet-357417.iam.gserviceaccount.com"
  ]
}