# module used to create the components
# in order to create the app, the individual components need to be created

#Step 1: create the health check
module "health_check" {
  source = "../health_check"

  health_checks = [{
    name                = "hc-${var.app_name}-tcp"
    description         = "Health check for app: ${var.app_name}"
    check_interval_sec  = var.hc_check_interval_sec
    healthy_threshold   = var.hc_healthy_threshold
    timeout_sec         = var.hc_timeout_sec
    unhealthy_threshold = var.hc_unhealthy_threshold
    host                = var.hc_host
    port_name           = "port-${var.app_name}"
    port_specification  = var.hc_port_specification
    proxy_header        = var.hc_proxy_header
    response            = var.hc_response
    region              = var.region
  }]
}

#Step 2: create the regional MIG
module "MIG" {
  source = "../MIGS"
  # ensure we create a MIG only oncce the health check is created
  depends_on = [
    module.health_check
  ]

  project      = var.project
  debug        = var.debug
  health_check = module.health_check.healthcheck_id

  templates = [{
    name                    = "ds-${var.app_name}"
    service_account         = var.service_account_name
    labels                  = var.labels
    network                 = var.network
    subnetwork              = var.subnetwork
    retry                   = var.retry
    max_instances           = var.max_instances
    ram                     = var.ram
    cpu                     = var.cpu
    per_vm                  = 1
    zones                   = var.zones
    region                  = var.region
    container_name          = var.container_name
    network_tags            = var.network_tags
    machine_type            = var.machine_type
    disk_size               = var.disk_size
    named_port              = "port-${var.app_name}"
    port                    = var.port
    scopes                  = var.scopes
    environmental_variables = var.environmental_variables
    capacity                = var.capacity
  }]
}

# Step 3: create the backend service
module "backend" {
  source = "../backend_service"
  # ensure we only create the backend service once the MIG and Health check is created
  depends_on = [
    module.health_check,
    module.MIG
  ]
  group         = module.MIG.igm_instance_group
  health_checks = module.health_check.healthcheck_id

  backends = [{
    name           = "bes-${var.app_name}"
    description    = "backend service for the app: ${var.app_name}"
    protocol       = var.be_protocol
    timeout_sec    = var.be_timeout_sec
    balancing_mode = var.be_balancing_mode
  }]
}
# step 4 create the url map

module "url_map" {
  source = "../url_map"
  # ensure backend service is created first before creating forwarding rule
  depends_on = [
    module.backend
  ]
  url_maps = [{
    name               = "${var.app_name}-urlmap"
    description        = "url map for: ${var.app_name}"
    backend_service_id = module.backend.backend_service
    hosts              = var.hosts
    paths              = var.paths
  }]

}

# step 5 create the target proxy
module "target_proxy" {
  source = "../target_proxy"
  depends_on = [
    module.url_map
  ]
  target_proxies = [{
    name    = "tp-${var.app_name}"
    url_map = module.url_map.url_map
  }]
}

#Step 6 create the forwarding rule
module "forwarding_rule" {
  source = "../forwarding_rule"
  # ensure target_proxy is created first before creating forwarding rule
  depends_on = [
    module.target_proxy
  ]

  forwarding_rules = [{
    name         = "fr-${var.app_name}"
    ip_protocol  = var.ip_protocol
    description  = "forwarding rule for app: ${var.app_name}"
    port_range   = "80"
    ip_address   = var.fr_ip_address
    target_proxy = module.target_proxy.target_proxy_self_link
  }]
}
