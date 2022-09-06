provider "newrelic" {
  account_id    = var.newrelic_account_id
  api_key       = var.newrelic_api_key
  admin_api_key = var.newrelic_admin_api_key
  region        = var.newrelic_region
}

provider "pagerduty" {
  token = var.pagerduty_api_token
}

data "pagerduty_vendor" "newrelic" {
  name = "New Relic"
}

data "pagerduty_user" "dummy" {
  email = var.pagerduty_user_email
}

data "pagerduty_team" "dummy" {
  name = var.pagerduty_team_name
}

resource "pagerduty_schedule" "dummy" {
  name      = "Test Dummy On-Call Schedule"
  time_zone = "Europe/Madrid"

  layer {
    name                         = "Weekly Shift"
    start                        = "2022-09-06T09:00:00Z"
    rotation_virtual_start       = "2022-09-06T14:00:00Z"
    rotation_turn_length_seconds = 604800
    users                        = [data.pagerduty_user.dummy.id]
  }

  teams = [data.pagerduty_team.dummy.id]
}

resource "pagerduty_escalation_policy" "dummy" {
  name      = "Test Dummy Escalation Policy"
  num_loops = 2
  teams     = [data.pagerduty_team.dummy.id]

  rule {
    escalation_delay_in_minutes = 30

    target {
      type = "schedule_reference"
      id   = pagerduty_schedule.dummy.id
    }
  }
}

resource "pagerduty_service" "dummy" {
  name                    = "Test Dummy Service"
  description             = "A Dummy Service for testing terraform purposes"
  acknowledgement_timeout = 600
  auto_resolve_timeout    = "null"
  escalation_policy       = pagerduty_escalation_policy.dummy.id
  alert_creation          = "create_alerts_and_incidents"

  alert_grouping_parameters {
    type = "intelligent"
  }

  incident_urgency_rule {
    type    = "constant"
    urgency = "severity_based"
  }

  depends_on = [
    data.pagerduty_user.dummy
  ]
}

resource "pagerduty_service_integration" "newrelic" {
  name    = data.pagerduty_vendor.newrelic.name
  service = pagerduty_service.dummy.id
  vendor  = data.pagerduty_vendor.newrelic.id
}

module "newrelic_monitoring" {
  source = "../"

  newrelic_account_id = var.newrelic_account_id

  newrelic_app_name                 = var.newrelic_app_name
  newrelic_fully_qualified_app_name = var.newrelic_fully_qualified_app_name

  service_healthcheck_url = var.service_healthcheck_url
  enable_dashboard        = true

  enable_victorops_notifications = false

  alert_error_rate_enable = true

  enable_pagerduty_notifications = true
  pagerduty_service_key          = pagerduty_service_integration.newrelic.integration_key
}
