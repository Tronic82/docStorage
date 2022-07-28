variable "forwarding_rules" {
  type = list(object({
    # name of the forwarding rule. Required
    name = string
    # description of the forwarding rule. Optional
    description = string
    # ip protocol to use in the forwarding rule. Required
    ip_protocol = string
    # list of ports. Required
    port_range = string
    # the ip address of the forwarding rule. Required
    ip_address = string
    # target proxy to attach
    target_proxy = string
  }))
  description = "List of forwarding rules"

  default = [{
    description  = "description"
    ip_address   = "1.2.3.4"
    ip_protocol  = "TCP"
    name         = "fwr-elb-1"
    port_range   = "80"
    target_proxy = "tp-1"
  }]
}
locals {
  defaults = {
    description = "description of the forwarding rule"
  }
  description          = "description"
  forwarding_rules_map = { for rules in var.forwarding_rules : rules["name"] => rules }
}
