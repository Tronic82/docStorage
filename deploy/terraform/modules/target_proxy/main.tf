resource "google_compute_target_http_proxy" "target_http_proxy" {
  for_each = local.target_proxy_map
  name     = each.value.name
  url_map  = each.value.url_map
}

output "target_proxy_self_link" {
  value = values(google_compute_target_http_proxy.target_http_proxy)[0].self_link
}
