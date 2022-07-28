variable "url_maps" {
  type = list(object({
    #name of url map. Required
    name        = string
    description = string
    #the id of the backend to use for url map. requried
    backend_service_id = string
    #list of host urls
    hosts = list(string)
    # list of path for url
    paths  = list(string)
  }))
  description = "url maps"
  default = [{
    backend_service_id = "backend_service1"
    description        = "description of url map"
    hosts              = ["myhost.com"]
    name               = "url_map1"
    paths              = ["/home"]
  }]

}
locals {
  defaults = {
    description = "description of a url map"
  }
  description = "description"
  urlmap_map  = { for urlmaps in var.url_maps : urlmaps["name"] => urlmaps }
}
