variable "target_proxies" {
  type = list(object({
    #name of the target proxy
    name = string
    # url map to assign to the target proxy
    url_map = string
  }))
  description = "A list of target proxies to configure"
  default = [{
    name    = "target_proxy_1"
    url_map = "url_map_1"
  }]
}
locals {
  target_proxy_map = { for proxy in var.target_proxies : proxy["name"] => proxy }
}
