variable "project" {
  type        = string
  description = "project to deploy resources in"
}

variable "debug" {
  type        = bool
  description = "Debug set to true enabless ssh onto VMs"
  default     = false
}

variable "health_check" {
  description = "health check resource"
}

variable "templates" {
  type = list(object({
    # name of the template. must be unique. Required
    name = string
    # the service account the instance will run as. must already exist. Required
    service_account = string
    # labels to apply to instances. Optional, default to empty map
    labels = map(string)
    # network to host the instance, must already exist. Required
    network = string
    # subnetwork to host the instance, must already exist. Required
    subnetwork = string
    # retry on failure or not. Optional, default to false
    retry = bool
    # max number of vm in MIG. Required
    max_instances = number
    # environmental variables. list in the form ENV_VAR=ENV_VALUE. Optional, default to empty list
    environmental_variables = list(string)
    # amount of RAM needed in mb. Optional, default to 256mb
    ram = number
    # Number of CPU to allocate. Optional, defaults to 1 cpu
    cpu = number
    # the container to execute in the form <container_name>:<tag>. Required
    container_name = string
    # Any network tags to apply to VM as a list of tags. Optional, defaults to empty list
    network_tags = list(string)
    # the machine type of the VM to use. Optional, defaults to e2-small
    machine_type = string
    # size of disk to allocate to vm in GB. Optional, default to 10GB
    disk_size = number
    # list of Scopes to give to the vm. Optional, defaults to all cloud scopes
    scopes = list(string)
    # number of containers to pack on to each VM. Optional, defaults to 1
    per_vm = number
    # port to be exposed. required
    port = number
    # the region to deploy the vms. required
    region = string
    # list of zones to deploy to in the region. Required
    zones = list(string)
    # the name of the port. Required
    named_port = string
    # the capacity for load balancing. required
    capacity = number

  }))

  description = "defines the instance values"
  default = [{
    capacity                = 0.8
    container_name          = "eu/gcr.io/docstorage/docstorage:latest"
    cpu                     = 1
    disk_size               = 1
    environmental_variables = []
    labels                  = {}
    machine_type            = "e2-small"
    max_instances           = 1
    name                    = "instance-name-1"
    network                 = "network-name-1"
    network_tags            = []
    per_vm                  = 1
    port                    = 80
    named_port              = "value"
    ram                     = 1
    region                  = "europe-west1"
    retry                   = false
    scopes                  = []
    service_account         = "SA-1"
    subnetwork              = "subnet-1"
    zones                   = []
  }]

}

locals {
  defaults = {
    cpu                     = 1
    disk_size               = 10
    environmental_variables = []
    labels                  = {}
    machine_type            = "e2-small"
    network_tags            = []
    per_vm                  = 1
    ram                     = 256
    retry                   = false
    scopes                  = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  cpu                     = "cpu"
  disk_size               = "disk_size"
  environmental_variables = "environmental_variables"
  labels                  = "labels"
  machine_type            = "machine_type"
  network_tags            = "network_tags"
  per_vm                  = "per_vm"
  ram                     = "ram"
  retry                   = "retry"
  scopes                  = "scopes"
  kms_project             = var.project
  template_map            = { for template in var.templates : template["name"] => template }
}
