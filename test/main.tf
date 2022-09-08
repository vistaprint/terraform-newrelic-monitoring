provider "newrelic" {
  account_id    = var.newrelic_account_id
  api_key       = var.newrelic_api_key
  admin_api_key = var.newrelic_admin_api_key
  region        = var.newrelic_region
}

provider "pagerduty" {
  token = var.pagerduty_api_token
}
