resource "google_compute_instance_template" "docstorage_template" {
  for_each    = local.template_map
  name_prefix = "ds-"
  description = "This template is used to create the app MIG"
  tags        = lookup(each.value, local.network_tags, local.defaults.network_tags)
  labels      = lookup(each.value, local.labels, local.defaults.labels)

  instance_description = "Instances to run: ${each.value.name}"
  machine_type         = lookup(each.value, local.machine_type, local.defaults.machine_type)
  can_ip_forward       = false
  lifecycle {
    create_before_destroy = true
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  // create a new boot disk from an image
  disk {
    auto_delete = true
    disk_encryption_key {
      kms_key_self_link = "projects/${local.kms_project}/locations/${each.value.region}/keyRings/${each.value.region}-keyring/cryptoKeys/compute"
    }
    disk_type    = "pd-standard"
    disk_size_gb = lookup(each.value, local.disk_size, local.defaults.disk_size)
    source_image = "projects/cos-cloud/global/images/family/cos-stable"
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloud_init.tmpl", {
      debug = var.debug,
      containers = [
        for i in range(lookup(each.value, local.per_vm, local.defaults.per_vm)) : {
          id    = i
          name  = "${each.key}${i}"
          image = each.value.container_name
          env   = lookup(each.value, "environmental_variables", local.defaults.environmental_variables)
          port  = each.value.port
          resources = {
            limits = {
              memory = each.value.ram
              cpu    = lookup(each.value, local.cpu, local.defaults.cpu)
            }
          }
        }
      ]
    })
  }

  service_account {
    email  = "${each.value.service_account}@${var.project}.iam.gserviceaccount.com"
    scopes = lookup(each.value, local.scopes, local.defaults.scopes)
  }

}

# now to create instance group manager
resource "google_compute_region_instance_group_manager" "docstorage_igm" {
  for_each                  = local.template_map
  name                      = "docstorage-mig-${each.key}"
  base_instance_name        = "docstorage-mig-${each.key}"
  distribution_policy_zones = each.value.zones
  # need to have at least one running at all times
  target_size = length(each.value.zones)
  description = "The instance group to support the docstorage instances"
  update_policy {
    type            = "PROACTIVE"
    minimal_action  = "REPLACE"
    max_surge_fixed = length(each.value.zones)
  }

  version {
    instance_template = google_compute_instance_template.docstorage_template[each.key].id
  }

  named_port {
    name = each.value.named_port
    port = each.value.port
  }

  region = each.value.region

  auto_healing_policies {
    health_check      = var.health_check
    initial_delay_sec = 600
  }
}

# connect an autoscale to autoscale based on requests
resource "google_compute_region_autoscaler" "docstorage_scaler" {
  depends_on = [
    google_compute_region_instance_group_manager.docstorage_igm
  ]
  for_each = local.template_map
  name     = "scalar-${each.key}"
  region   = each.value.region
  target   = google_compute_region_instance_group_manager.docstorage_igm[each.key].id

  autoscaling_policy {
    max_replicas    = each.value.max_instances
    min_replicas    = length(each.value.zones)
    cooldown_period = 15
    mode            = "ON"
    load_balancing_utilization {
      target = each.value.capacity
    }
  }
}

output "igm_instance_group" {
  value = values(google_compute_region_instance_group_manager.docstorage_igm)[0].instance_group

}
