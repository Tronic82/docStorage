variable "service_accounts" {
  type = list(object({
    account_id   = string
    display_name = string
    description  = string
  }))
}

variable "project_id" {
  type = string
}
