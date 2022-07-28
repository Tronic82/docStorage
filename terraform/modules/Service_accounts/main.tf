resource "google_service_account" "accounts" {
  for_each     = { for account in var.service_accounts : account.account_id => account }
  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}
