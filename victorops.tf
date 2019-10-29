resource "newrelic_alert_channel" "victorops_non_urgent" {
  count = var.enable_victorops_notifications ? 1 : 0

  name = "${var.newrelic_fully_qualified_app_name} Non Urgent"
  type = "victorops"

  configuration = {
    key       = var.victorops_api_key
    route_key = var.victorops_non_urgent_routing_key
  }
}

resource "newrelic_alert_channel" "victorops_urgent" {
  count = var.enable_victorops_notifications ? 1 : 0

  name = "${var.newrelic_fully_qualified_app_name} Urgent"
  type = "victorops"

  configuration = {
    key       = var.victorops_api_key
    route_key = var.victorops_urgent_routing_key
  }
}

resource "newrelic_alert_policy_channel" "victorops_non_urgent" {
  count = var.enable_victorops_notifications ? 1 : 0

  policy_id  = newrelic_alert_policy.non_urgent.id
  channel_id = newrelic_alert_channel.victorops_non_urgent.0.id
}

resource "newrelic_alert_policy_channel" "victorops_urgent" {
  count = var.enable_victorops_notifications ? 1 : 0

  policy_id  = newrelic_alert_policy.urgent.id
  channel_id = newrelic_alert_channel.victorops_urgent.0.id
}
