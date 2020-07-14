provider "newrelic" {
  account_id    = var.newrelic_account_id
  api_key       = var.newrelic_api_key
  admin_api_key = var.newrelic_admin_api_key
  region        = var.newrelic_region
}

module "newrelic_monitoring" {
  source = "../"

  newrelic_account_id = var.newrelic_account_id

  newrelic_app_name                 = var.newrelic_app_name
  newrelic_fully_qualified_app_name = var.newrelic_fully_qualified_app_name

  service_healthcheck_url = var.service_healthcheck_url
  enable_dashboard        = true

  enable_victorops_notifications   = true
  victorops_api_key                = var.victorops_api_key
  victorops_urgent_routing_key     = var.victorops_urgent_routing_key
  victorops_non_urgent_routing_key = var.victorops_non_urgent_routing_key

  alert_error_rate_enable = true
}
