output "non_urgent_policy_id" {
  value = newrelic_alert_policy.non_urgent.id
}

output "urgent_policy_id" {
  value = newrelic_alert_policy.urgent.id
}
