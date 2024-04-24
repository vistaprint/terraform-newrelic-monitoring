locals {
  summary       = "{{ annotations.title.[0] }}"
  customDetails = <<-EOT
    {
      "condition_name": {{json accumulations.conditionName.[0]}},
      "details": {{json issueTitle}},
      "duration": {{#if issueDurationMs}}{{issueDurationMs}}{{else}}0{{/if}},
      "event_type": "INCIDENT",
      "incident_acknowledge_url": {{json issueAckUrl}},
      "incident_url": {{json issuePageUrl}},
      "policy_name": {{json accumulations.policyName.[0]}},
      {{#if accumulations.runbookUrl}}"runbook_url": {{json accumulations.runbookUrl.[0]}},{{/if}}
      "severity": "{{#eq 'HIGH' priority}}WARNING{{else}}{{priority}}{{/eq}}",
      "status": {{json status}},
      "timestamp": {{updatedAt}},
      "timestamp_utc_string": {{json issueUpdatedAt}}
    }
    EOT
}

resource "newrelic_notification_destination" "pagerduty" {
  count = var.enable_pagerduty_notifications ? 1 : 0

  account_id = var.newrelic_account_id
  name       = var.newrelic_app_name
  type       = "PAGERDUTY_SERVICE_INTEGRATION"


  auth_token {
    prefix = "Token token="
    token  = var.pagerduty_service_key
  }

  property {
    key   = "two_way_integration"
    value = "false"
  }
}

resource "newrelic_notification_channel" "pagerduty_urgent_channel" {
  count = var.enable_pagerduty_notifications ? 1 : 0

  account_id     = var.newrelic_account_id
  name           = var.newrelic_app_name
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.pagerduty[0].id
  product        = "IINT"

  property {
    key   = "summary"
    value = local.summary
  }

  property {
    key   = "customDetails"
    value = local.customDetails
  }
}

resource "newrelic_notification_channel" "pagerduty_non_urgent_channel" {
  count = var.enable_pagerduty_notifications ? 1 : 0

  account_id     = var.newrelic_account_id
  name           = var.newrelic_app_name
  type           = "PAGERDUTY_SERVICE_INTEGRATION"
  destination_id = newrelic_notification_destination.pagerduty[0].id
  product        = "IINT"

  property {
    key   = "summary"
    value = "{{ annotations.title.[0] }}"
  }

  property {
    key   = "customDetails"
    value = local.customDetails
  }
}

resource "newrelic_workflow" "non_urgent_workflow" {
  name                  = "${var.newrelic_fully_qualified_app_name} PagerDuty Non Urgent Workflow"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Urgent Policy"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.non_urgent.id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.pagerduty_non_urgent_channel[0].id
  }
}

resource "newrelic_workflow" "urgent_workflow" {
  name                  = "${var.newrelic_fully_qualified_app_name} PagerDuty Urgent Workflow"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Urgent Policy"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.urgent.id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.pagerduty_urgent_channel[0].id
  }
}