# create forwarding rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  for_each              = local.forwarding_rules_map
  name                  = each.value.name
  ip_protocol           = each.value.ip_protocol
  load_balancing_scheme = "EXTERNAL"
  port_range            = each.value.port_range
  ip_address            = each.value.ip_address
  description           = lookup(each.value, local.description, local.defaults.description)
  target                = each.value.target_proxy
}
