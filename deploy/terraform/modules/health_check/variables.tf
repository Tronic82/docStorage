variable "health_checks" {
  type = list(object({
    # name of the health check. Required
    name = string
    # how often in seconds to send a health check. Required
    check_interval_sec = number
    # description of the health check. Optional
    description = string
    # the threshold at which an unhealthy instance will be marked as healthy. Required
    healthy_threshold = number
    # how long to wait in seconds to wait before claiming failure. timeout_sec must be < check_interval_sec. Required
    timeout_sec = number
    # the threshold at which an healthy instance will be marked as unhealthy. Required
    unhealthy_threshold = number
    # the value of the host header in the health check. Required
    #host = string
    # the bytes to match against the begining of the response data. Must be in ASCII. Required
    response = string
    # the port name defined in the instanceGroup Named port. Required
    port_name = string
    # specify the typen of proxy header to append. Can be either NONE or PROXY_V1. Required
    proxy_header = string
    # specify how the port is selcted for health checking. Required
    port_specification = string
    # region to deploy health check
    region = string
  }))
  description = "List of health checks"
  default = [{
    check_interval_sec  = 1
    description         = "description"
    healthy_threshold   = 1
    #host                = "1.2.3.4"
    name                = "health_check_1"
    port_name           = "port_1"
    port_specification  = "USE_NAMED_PORT"
    proxy_header        = "NONE"
    response            = "HEALTHY"
    timeout_sec         = 1
    unhealthy_threshold = 1
    region              = "europe-west1"
  }]
}

locals {
  defaults = {
    description = "description of a health check"
    #host        = ""
  }
  description      = "description"
  #host             = "host"
  health_check_map = { for check in var.health_checks : check["name"] => check }
}
