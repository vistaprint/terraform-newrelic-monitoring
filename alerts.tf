data "newrelic_application" "app" {
  name = var.newrelic_fully_qualified_app_name
}

resource "newrelic_alert_policy" "non_urgent" {
  name = "${var.newrelic_fully_qualified_app_name} Non Urgent"
}

resource "newrelic_alert_policy" "urgent" {
  name = "${var.newrelic_fully_qualified_app_name} Urgent"
}

# health check monitor

resource "newrelic_synthetics_monitor" "health_check" {
  count = var.synthetics_monitor_health_endpoint_url != null ? 1 : 0

  name      = "${var.newrelic_fully_qualified_app_name}"
  type      = "SIMPLE"
  uri       = var.synthetics_monitor_health_endpoint_url
  frequency = var.synthetics_monitor_frequency
  status    = "ENABLED"
  locations = ["AWS_US_EAST_1", "AWS_US_WEST_1", "AWS_EU_WEST_1", "AWS_EU_WEST_3", "AWS_AP_NORTHEAST_1", "AWS_AP_SOUTHEAST_2"]
  bypass_head_request = var.synthetics_monitor_bypass_head_request
}

# urgent conditions

resource "newrelic_synthetics_alert_condition" "health_check" {
  count = var.synthetics_monitor_health_endpoint_url != null ? 1 : 0

  policy_id = newrelic_alert_policy.urgent.id

  name        = "Health check"
  monitor_id  = newrelic_synthetics_monitor.health_check.0.id
  runbook_url = var.runbook_url
}

resource "newrelic_nrql_alert_condition" "error_rate" {
  count = var.alert_error_rate_enable ? 1 : 0

  policy_id = newrelic_alert_policy.urgent.id

  name        = "Too many sustained errors"
  runbook_url = var.runbook_url
  enabled     = true

  term {
    duration      = var.alert_error_rate_duration
    operator      = "above"
    priority      = "critical"
    threshold     = var.alert_error_rate_threshold
    time_function = "all"
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

    since_value = "3" # minutes
  }

  value_function = "single_value"
}

resource "newrelic_nrql_alert_condition" "error_rate_5xx" {
  count = var.alert_error_rate_5xx_enable ? 1 : 0

  policy_id = newrelic_alert_policy.urgent.id

  name        = "Too many sustained 5xx errors"
  runbook_url = var.runbook_url
  enabled     = true

  term {
    duration      = var.alert_error_rate_5xx_duration
    operator      = "above"
    priority      = "critical"
    threshold     = var.alert_error_rate_5xx_threshold
    time_function = "all"
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

    since_value = "3" # minutes
  }

  value_function = "single_value"
}

resource "newrelic_nrql_alert_condition" "high_latency_urgent" {
  policy_id = newrelic_alert_policy.urgent.id

  name        = "High latency for 50% of requests"
  runbook_url = var.runbook_url
  enabled     = true

  term {
    duration      = var.alert_high_latency_urgent_duration
    operator      = "above"
    priority      = "critical"
    threshold     = var.alert_high_latency_urgent_threshold
    time_function = "all"
  }

  nrql {
    query = <<-EOF
        SELECT percentile(duration * 1000, 50)
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        EOF

    since_value = "3" # minutes
  }

  value_function = "single_value"
}

# non-urgent conditions

resource "newrelic_nrql_alert_condition" "error_rate_4xx" {
  count = var.alert_error_rate_4xx_enable ? 1 : 0

  policy_id = newrelic_alert_policy.non_urgent.id

  name        = "Too many sustained 4xx errors"
  runbook_url = var.runbook_url
  enabled     = true

  term {
    duration      = var.alert_error_rate_4xx_duration
    operator      = "above"
    priority      = "critical"
    threshold     = var.alert_error_rate_4xx_threshold
    time_function = "all"
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
        EOF

    since_value = "3" # minutes
  }

  value_function = "single_value"
}

resource "newrelic_nrql_alert_condition" "high_latency_non_urgent" {
  policy_id = newrelic_alert_policy.non_urgent.id

  name        = "High latency for 1% of requests"
  runbook_url = var.runbook_url
  enabled     = true

  term {
    duration      = var.alert_high_latency_non_urgent_duration
    operator      = "above"
    priority      = "critical"
    threshold     = var.alert_high_latency_non_urgent_threshold
    time_function = "all"
  }

  nrql {
    query = <<-EOF
        SELECT percentile(duration * 1000, 99)
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        EOF

    since_value = "3" # minutes
  }

  value_function = "single_value"
}
