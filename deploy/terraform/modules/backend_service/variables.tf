variable "group" {
  description = "Instance Group ID"
}

variable "health_checks" {
  description = "Health check ID"
}

variable "backends" {
  type = list(object({
    # name of the backend service. Required
    name = string
    # description of the backend service. Optional
    description = string
    # blancing mode used. Required
    balancing_mode = string
    # protocol to use with the backend service. Required
    protocol = string
    # how long to wait for the time out. Required
    timeout_sec = number
  }))
  description = "A list of backend services"
  default = [{
    balancing_mode = "UTILIZATION"
    description    = "elb for backend 1"
    name           = "elb-1"
    protocol       = "TCP"
    timeout_sec    = 10
  }]

}
locals {
  defaults = {
    description = "description of the backend service"
  }
  description = "description"

  backend_services_map = { for backend in var.backends : backend["name"] => backend }
}
