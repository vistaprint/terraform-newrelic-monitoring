terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = ">= 3"
    }
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = ">= 3"
    }
  }
  required_version = ">= 1"
}
