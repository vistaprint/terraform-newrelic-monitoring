data "newrelic_entity" "app" {
  name = var.newrelic_fully_qualified_app_name
  type = "APPLICATION"
}

resource "newrelic_alert_policy" "non_urgent" {
  account_id = var.newrelic_account_id
  name       = "${var.newrelic_app_name} Non Urgent"
}

resource "newrelic_alert_policy" "urgent" {
  account_id = var.newrelic_account_id
  name       = "${var.newrelic_app_name} Urgent"
}

# health check monitor

resource "newrelic_synthetics_monitor" "health_check" {
  count = var.service_healthcheck_url != null ? 1 : 0

  name      = "${var.newrelic_app_name} Health check"
  type      = "SIMPLE"
  uri       = var.service_healthcheck_url
  frequency = 1
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1", "AWS_US_WEST_1", "AWS_EU_WEST_1", "AWS_EU_WEST_3", "AWS_AP_NORTHEAST_1", "AWS_AP_SOUTHEAST_2"]
}

# urgent conditions

resource "newrelic_synthetics_alert_condition" "health_check" {
  count = var.service_healthcheck_url != null ? 1 : 0

  policy_id = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: health check"
  monitor_id  = newrelic_synthetics_monitor.health_check[0].id
  runbook_url = var.runbook_url
}

resource "newrelic_nrql_alert_condition" "error_rate" {
  count = var.alert_error_rate_enable ? 1 : 0

  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: too many sustained errors"
  runbook_url = var.runbook_url
  enabled     = true

  value_function               = "single_value"
  violation_time_limit_seconds = 86400

  critical {
    operator              = "above"
    threshold             = var.alert_error_rate_threshold
    threshold_duration    = var.alert_error_rate_duration
    threshold_occurrences = "ALL"
  }

  # The operation 'percentage(count(*), WHERE error IS TRUE)' can be represented as follows:
  #
  # Transaction events with error
  # –––––––––––––––––––––––––––––
  # Transaction events (overall)
  #
  # For intervals with no events the operation ends up being 0 / 0, which returns NULL.
  # To avoid this problem we use a query that ensures the denominator is always a non-zero value.
  nrql {
    query = <<-EOF
        SELECT 100 * (
          filter(count(*), WHERE error IS TRUE) / (count(*) + 1e-10)
        ) as Percentage
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        EOF

    evaluation_offset = "3" # minutes
  }
}

resource "newrelic_nrql_alert_condition" "error_rate_5xx" {
  count = var.alert_error_rate_5xx_enable ? 1 : 0

  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: too many sustained 5xx errors"
  runbook_url = var.runbook_url
  enabled     = true

  value_function               = "single_value"
  violation_time_limit_seconds = 86400

  critical {
    operator              = "above"
    threshold             = var.alert_error_rate_5xx_threshold
    threshold_duration    = var.alert_error_rate_5xx_duration
    threshold_occurrences = "ALL"
  }

  # The operation 'percentage(count(*), WHERE response.status LIKE '5%')' can be represented as follows:
  #
  # Transaction events with 5xx status code
  # ––––––––––––––––––––––––––––––––––––––
  #     Transaction events (overall)
  #
  # For intervals with no events the operation ends up being 0 / 0, which returns NULL.
  # To avoid this problem we use a query that ensures the denominator is always a non-zero value.
  nrql {
    query = <<-EOF
        SELECT 100 * (
          filter(count(*), WHERE ${var.response_status_variable_name} LIKE '5%') / (count(*) + 1e-10)
        ) as Percentage
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        EOF

    evaluation_offset = "3" # minutes
  }
}

resource "newrelic_nrql_alert_condition" "high_latency_urgent" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: high latency for 50% of requests"
  runbook_url = var.runbook_url
  enabled     = true

  value_function               = "single_value"
  violation_time_limit_seconds = 86400

  critical {
    operator              = "above"
    threshold             = var.alert_high_latency_urgent_threshold
    threshold_duration    = var.alert_high_latency_urgent_duration
    threshold_occurrences = "ALL"
  }

  nrql {
    query = <<-EOF
        SELECT percentile(duration * 1000, 50)
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        EOF

    evaluation_offset = "3" # minutes
  }
}

# non-urgent conditions

resource "newrelic_nrql_alert_condition" "error_rate_4xx" {
  count = var.alert_error_rate_4xx_enable ? 1 : 0

  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.non_urgent.id

  name        = "${var.newrelic_app_name}: too many sustained 4xx errors"
  runbook_url = var.runbook_url
  enabled     = true

  value_function               = "single_value"
  violation_time_limit_seconds = 86400

  critical {
    operator              = "above"
    threshold             = var.alert_error_rate_4xx_threshold
    threshold_duration    = var.alert_error_rate_4xx_duration
    threshold_occurrences = "ALL"
  }

  # The operation 'percentage(count(*), WHERE response.status LIKE '4%')' can be represented as follows:
  #
  # Transaction events with 4xx status code
  # ––––––––––––––––––––––––––––––––––––––
  #     Transaction events (overall)
  #
  # For intervals with no events the operation ends up being 0 / 0, which returns NULL.
  # To avoid this problem we use a query that ensures the denominator is always a non-zero value.
  nrql {
    query = <<-EOF
        SELECT 100 * (
          filter(count(*), WHERE ${var.response_status_variable_name} LIKE '4%') / (count(*) + 1e-10)
        ) as Percentage
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        ${var.alert_error_rate_4xx_conditions}
        EOF

    evaluation_offset = "3" # minutes
  }
}

resource "newrelic_nrql_alert_condition" "high_latency_non_urgent" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.non_urgent.id

  name        = "${var.newrelic_app_name}: high latency for 1% of requests"
  runbook_url = var.runbook_url
  enabled     = true

  value_function               = "single_value"
  violation_time_limit_seconds = 86400

  critical {
    operator              = "above"
    threshold             = var.alert_high_latency_non_urgent_threshold
    threshold_duration    = var.alert_high_latency_non_urgent_duration
    threshold_occurrences = "ALL"
  }

  nrql {
    query = <<-EOF
        SELECT percentile(duration * 1000, 99)
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        EOF

    evaluation_offset = "3" # minutes
  }
}
