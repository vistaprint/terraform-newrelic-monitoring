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

  name             = "${var.newrelic_app_name} Health check"
  type             = "SIMPLE"
  uri              = var.service_healthcheck_url
  period           = "EVERY_MINUTE"
  status           = "ENABLED"
  locations_public = ["US_EAST_1", "US_WEST_1", "EU_WEST_1", "EU_WEST_3", "AP_NORTHEAST_1", "AP_SOUTHEAST_2"]
}

# urgent conditions

resource "newrelic_nrql_alert_condition" "health_check" {
  count = var.service_healthcheck_url != null ? 1 : 0

  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: health check"
  runbook_url = var.runbook_url
  enabled     = true

  aggregation_method = "event_flow"
  aggregation_window = 60
  aggregation_delay  = 180
  slide_by           = 30

  violation_time_limit_seconds = 86400

  critical {
    operator              = "below"
    threshold             = newrelic_synthetics_monitor.health_check[0].period_in_minutes * 60
    threshold_duration    = var.alert_health_check_duration
    threshold_occurrences = "ALL"
  }

  nrql {
    query = <<-EOF
        SELECT count(*)
        FROM SyntheticCheck
        WHERE monitorName = '${newrelic_synthetics_monitor.health_check[0].name}'
        AND result = 'SUCCESS'
        FACET location
        EOF
  }
}

resource "newrelic_nrql_alert_condition" "error_rate" {
  count = var.alert_error_rate_enable ? 1 : 0

  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: too many sustained errors"
  runbook_url = var.runbook_url
  enabled     = true

  aggregation_method = "event_flow"
  aggregation_delay  = 180
  slide_by           = 30

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
  }
}

resource "newrelic_nrql_alert_condition" "high_latency_urgent" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.urgent.id

  name        = "${var.newrelic_app_name}: high latency for 50% of requests"
  runbook_url = var.runbook_url
  enabled     = true

  aggregation_method = "event_flow"
  aggregation_delay  = 180
  slide_by           = 30

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
  }
}

# urgent/non urgent conditions
resource "newrelic_nrql_alert_condition" "status_code_error_rate" {
  for_each = { for i, val in var.response_status_codes_alerts : i => val }

  account_id = var.newrelic_account_id
  policy_id  = each.value.isUrgent ? newrelic_alert_policy.urgent.id : newrelic_alert_policy.non_urgent.id

  name        = each.value.name
  runbook_url = var.runbook_url
  enabled     = true

  aggregation_method = "event_flow"
  aggregation_delay  = 180
  slide_by           = 30

  violation_time_limit_seconds = 86400

  critical {
    operator              = "above"
    threshold             = each.value.threshold
    threshold_duration    = each.value.duration
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
          filter(count(*), WHERE ${var.response_status_variable_name} LIKE '${each.value.nrql_value}') / (count(*) + 1e-10)
        ) as Percentage
        FROM Transaction
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        ${each.value.extra_conditions!=null?each.value.extra_conditions:""}
        EOF
  }
}

# non-urgent conditions

resource "newrelic_nrql_alert_condition" "high_latency_non_urgent" {
  account_id = var.newrelic_account_id
  policy_id  = newrelic_alert_policy.non_urgent.id

  name        = "${var.newrelic_app_name}: high latency for 1% of requests"
  runbook_url = var.runbook_url
  enabled     = true

  aggregation_method = "event_flow"
  aggregation_delay  = 180
  slide_by           = 30

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
  }
}
