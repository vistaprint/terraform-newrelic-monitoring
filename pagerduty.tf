locals {
  summary       = "{{ annotations.title.[0] }}"
  customDetails = <<-EOT
    {
      {{#if nrAccountId}}"account_id": {{nrAccountId}},{{/if}}
      "account_name": {{json accumulations.tag.account.[0]}},
      {{#if accumulations.tag.action}}"action":{{json accumulations.tag.action.[0]}},{{/if}}
      "closed_violations_count": {
          "critical": {{#if closedIncidentsCount}}{{closedIncidentsCount}}{{else}}0{{/if}},
          "warning": 0,
          "total": {{#if closedIncidentsCount}}{{closedIncidentsCount}}{{else}}0{{/if}}
      },
      "condition_family_id": {{accumulations.conditionFamilyId.[0]}},
      "condition_id": {{accumulations.conditionFamilyId.[0]}},
      "condition_name": {{json accumulations.conditionName.[0]}},
      {{#if accumulations.evaluationName}}"condition_metric_name": {{json accumulations.evaluationName.[0]}},{{/if}}
      {{#if accumulations.evaluationMetricValueFunction}}"condition_metric_value_function": {{json accumulations.evaluationMetricValueFunction.[0]}},{{/if}}
      "current_state": {{#if issueClosedAt}}"closed"{{else if issueAcknowledgedAt}}"acknowledged"{{else}}"open"{{/if}},
      "details": {{json issueTitle}},
      "duration": {{#if issueDurationMs}}{{issueDurationMs}}{{else}}0{{/if}},
      "event_type": "INCIDENT",
      "incident_acknowledge_url": {{json issueAckUrl}},
      {{#if labels.nrIncidentId}}"incident_id": {{labels.nrIncidentId.[0]}},{{/if}}
      "incident_url": {{json issuePageUrl}},
      "issue_id": {{json issueId}},
      "metadata": {
          {{#if locationStatusesObject}}"location_statuses": {{json locationStatusesObject}},{{/if}}
          {{#if accumulations.metadata_entity_type}}"entity.type": {{json accumulations.metadata_entity_type.[0]}},{{/if}}
          {{#if accumulations.metadata_entity_name}}"entity.name": {{json accumulations.metadata_entity_name.[0]}}{{/if}}
      },
      "open_violations_count": {
          "critical": {{#if openIncidentsCount}}{{openIncidentsCount}}{{else}}0{{/if}},
          "warning": 0,
          "total": {{#if openIncidentsCount}}{{openIncidentsCount}}{{else}}0{{/if}}
      },
      {{#if owner}}"owner": {{json owner}},{{/if}}
      "policy_name": {{json accumulations.policyName.[0]}},
      {{#if policyUrl}}"policy_url": {{json policyUrl}},{{/if}}
      "radar_entity": {
          "accountId": {{json accumulations.tag.accountId.[0]}},
          "domain": {{json accumulations.conditionProduct.[0]}},
          "domainId": {{json issueId}},
          "entityGuid": {{json entitiesData.entities.[0].id}},
          "name": {{#if accumulations.targetName}}{{json accumulations.targetName.[0]}}{{else if entitiesData.entities}}{{json entitiesData.entities.[0].name}}{{else}}"NA"{{/if}},
          "type": {{#if entitiesData.types.[0]}}{{json entitiesData.types.[0]}}{{else}}"NA"{{/if}}
      },
      {{#if accumulations.runbookUrl}}"runbook_url": {{json accumulations.runbookUrl.[0]}},{{/if}}
      "severity": "{{#eq 'HIGH' priority}}WARNING{{else}}{{priority}}{{/eq}}",
      "state": {{json state}},
      "status": {{json status}},
      "targets": [
          {
              "id": {{#if entitiesData.entities.[0].id}}{{json entitiesData.entities.[0].id}}{{else if accumulations.nrqlEventType}}{{json accumulations.nrqlEventType.[0]}}{{else}}"N/A"{{/if}},
              "name": {{#if accumulations.targetName}}{{json accumulations.targetName.[0]}}{{else if entitiesData.entities}}{{json entitiesData.entities.[0].name}}{{else}}"NA"{{/if}},
              "link": {{json issuePageUrl}},
              "product": {{json accumulations.conditionProduct.[0]}},
              "type": {{#if entitiesData.types.[0]}}{{json entitiesData.types.[0]}}{{else}}"NA"{{/if}},
              "labels": {
                  {{#each accumulations.rawTag}}"{{escape @key}}": {{#if this.[0]}}{{json this.[0]}}{{else}}"empty"{{/if}}{{#unless @last}},{{/unless}}{{/each}}
              }
          }
      ],
      "timestamp": {{updatedAt}},
      "timestamp_utc_string": {{json issueUpdatedAt}},
      "version": "1.0",
      {{#if accumulations.conditionDescription}}"VIOLATION DESCRIPTION": {{json accumulations.conditionDescription.[0]}},{{/if}}
      {{#if violationChartUrl}}"violation_chart_url": {{json violationChartUrl}},{{/if}}
      "violation_callback_url": {{json issuePageUrl}}
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