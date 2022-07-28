# create a backend service

resource "google_compute_backend_service" "docstorage_backend_service" {
  for_each              = local.backend_services_map
  name                  = each.value.name
  load_balancing_scheme = "EXTERNAL"
  protocol              = each.value.protocol
  timeout_sec           = each.value.timeout_sec
  description           = lookup(each.value, local.description, local.defaults.description)

  backend {
    group           = var.group
    balancing_mode  = each.value.balancing_mode
    capacity_scaler = 1
  }

  health_checks = [var.health_checks]
}

output "backend_service" {
  value = values(google_compute_backend_service.docstorage_backend_service)[0].id
}
