# create regional url map
resource "google_compute_url_map" "regionurlmap" {
  for_each        = local.urlmap_map
  name            = each.value.name
  description     = lookup(each.value, local.description, local.defaults.description)
  default_service = each.value.backend_service_id

  host_rule {
    hosts        = each.value.hosts
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = each.value.backend_service_id

    path_rule {
      paths   = each.value.paths
      service = each.value.backend_service_id
    }
  }
}

output "url_map" {
  value = values(google_compute_url_map.regionurlmap)[0].self_link
}
