resource "newrelic_alert_channel" "pagerduty" {
  count = var.enable_pagerduty_notifications ? 1 : 0

  name = var.newrelic_app_name
  type = "pagerduty"

  config {
    service_key = var.pagerduty_service_key
  }
}

resource "newrelic_alert_policy_channel" "pagerduty_non_urgent" {
  count = var.enable_pagerduty_notifications ? 1 : 0

  policy_id   = newrelic_alert_policy.non_urgent.id
  channel_ids = [newrelic_alert_channel.pagerduty[0].id]
}

resource "newrelic_alert_policy_channel" "pagerduty_urgent" {
  count = var.enable_pagerduty_notifications ? 1 : 0

  policy_id   = newrelic_alert_policy.urgent.id
  channel_ids = [newrelic_alert_channel.pagerduty[0].id]
}
