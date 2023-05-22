module "newrelic_monitoring" {
  source = "../"

  newrelic_account_id = var.newrelic_account_id

  newrelic_app_name                 = var.newrelic_app_name
  newrelic_fully_qualified_app_name = var.newrelic_fully_qualified_app_name

  service_healthcheck_url = var.service_healthcheck_url
  enable_dashboard        = true

  alert_error_rate_enable = true

  enable_pagerduty_notifications = true
  pagerduty_service_key          = pagerduty_service_integration.newrelic.integration_key
}
