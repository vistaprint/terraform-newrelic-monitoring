module "newrelic_monitoring" {
  source = "../"

  newrelic_account_id = var.newrelic_account_id

  newrelic_app_name                 = var.newrelic_app_name
  newrelic_fully_qualified_app_name = var.newrelic_fully_qualified_app_name

  status_code_alerts = [
    {
      name                = "${var.newrelic_app_name}: too many sustained 4xx errors"
      status_code_pattern = "4%"
      urgent              = false
      duration            = 300
      threshold           = 30
    },
    {
      name                  = "${var.newrelic_app_name}: too many sustained 429 errors"
      status_code_pattern   = "429"
      urgent                = true
      duration              = 300
      threshold             = 20
      extra_nrql_conditions = "1=1"
    },
    {
      name                = "${var.newrelic_app_name}: too many sustained 5xx errors"
      status_code_pattern = "5%"
      urgent              = true
      duration            = 300
      threshold           = 10
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
