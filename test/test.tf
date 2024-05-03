module "newrelic_monitoring" {
  source = "../"

  newrelic_account_id = var.newrelic_account_id

  newrelic_app_name                 = var.newrelic_app_name
  newrelic_fully_qualified_app_name = var.newrelic_fully_qualified_app_name

  response_status_codes_alerts = [
    {
      name       = "${var.newrelic_app_name}: too many sustained 4xx errors"
      nrql_value = "4%"
      isUrgent   = false
      duration   = 300
      threshold  = 30
    },
    {
      name             = "${var.newrelic_app_name}: too many sustained 429 errors"
      nrql_value       = "429"
      isUrgent         = true
      duration         = 300
      threshold        = 20
      extra_conditions = "AND 1=1"
    },
    {
      name       = "${var.newrelic_app_name}: too many sustained 5xx errors"
      nrql_value = "5%"
      isUrgent   = true
      duration   = 300
      threshold  = 10
    },
  ]

  service_healthcheck_url = var.service_healthcheck_url
  enable_dashboard        = true

  alert_error_rate_enable = true

  enable_pagerduty_notifications = true
  pagerduty_service_key          = pagerduty_service_integration.newrelic.integration_key

  create_default_slos            = true
  latency_slo_duration_threshold = 0.1
}
