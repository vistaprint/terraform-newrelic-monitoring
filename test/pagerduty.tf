data "pagerduty_vendor" "newrelic" {
  name = "New Relic"
}

data "pagerduty_user" "user" {
  email = var.pagerduty_user_email
}

data "pagerduty_team" "team" {
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
    users                        = [data.pagerduty_user.user.id]
  }

  teams = [data.pagerduty_team.team.id]
}

resource "pagerduty_escalation_policy" "dummy" {
  name      = "Test Dummy Escalation Policy"
  num_loops = 2
  teams     = [data.pagerduty_team.team.id]

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
    data.pagerduty_user.user
  ]
}

resource "pagerduty_service_integration" "newrelic" {
  name    = data.pagerduty_vendor.newrelic.name
  service = pagerduty_service.dummy.id
  vendor  = data.pagerduty_vendor.newrelic.id
}
