variable "app_name" {
  type = string
}

variable "be_balancing_mode" {
  type = string
}

variable "be_protocol" {
  type = string
}

variable "be_timeout_sec" {
  type = number
  default = 10
}

variable "container_name" {
  type = string
}

variable "cpu" {
  type = number
  default = 1
}

variable "debug" {
  type = bool
  default = false
}

variable "disk_size" {
  type = number
  default = 10
}

variable "environmental_variables" {
  type = list(string)
  default = [  ]
}

variable "fr_ip_address" {
  type = string
}

# health check variables
variable "hc_check_interval_sec" {
  type = number
  default = 200
}

variable "hc_healthy_threshold" {
  type = number
  default = 5
}

variable "hc_host" {
  type = string
  default = null
}

variable "hc_port_specification" {
  type = string
  default = "USE_FIXED_PORT"
}

variable "hc_proxy_header" {
  type = string
  default = null
}

variable "hc_request_path" {
  type = string
  default = "/"
}

variable "hc_response" {
  type = string
  default = ""
}

variable "hc_timeout_sec" {
  type = number
  default = 120
}

variable "hc_unhealthy_threshold" {
  type = number
  default = 10
}

variable "ip_protocol" {
  type = string
}

variable "labels" {
  type = map(string)
  default = {}
}

variable "machine_type" {
  type = string
  default = "e2-small"
}

variable "max_instances" {
  type = number
  default = 5
}

variable "network" {
  type = string
}

variable "network_tags" {
  type = list(string)
  default = []
}

variable "port" {
  type = number
}

variable "project" {
  type = string
}

variable "ram" {
  type = number
  default = 256
}

variable "capacity" {
  type = number
  default = 0.8
}

variable "region" {
  type = string
}

variable "retry" {
  type = bool
  default = true
}

variable "scopes" {
  type = list(string)
  default = [ "https://www.googleapis.com/auth/cloud-platform" ]
}

variable "service_account_name" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "hosts" {
  type = list(string)
}

variable "paths" {
  type = list(string)
}