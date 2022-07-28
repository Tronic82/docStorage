# create a health check

resource "google_compute_health_check" "tcp_hc" {
  for_each            = local.health_check_map
  name                = each.value.name
  description         = lookup(each.value, local.description, local.defaults.description)
  timeout_sec         = each.value.timeout_sec
  check_interval_sec  = each.value.check_interval_sec
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  #region              = each.value.region
  # port                = 80
  #host                = lookup(each.value, local.host, local.defaults.host)
  #request_path        = each.value.request_path

  tcp_health_check  {
    #port_name          = each.value.port_name
    port               = 80
    port_specification = each.value.port_specification
    #host               = lookup(each.value, local.host, local.defaults.host)
    proxy_header       = "NONE"
    response           = ""
  }

  log_config {
    enable = true # log all health checks
  }
}

output "healthcheck_id" {
  value = values(google_compute_health_check.tcp_hc)[0].id
}
