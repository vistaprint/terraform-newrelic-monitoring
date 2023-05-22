terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = ">= 3"
    }
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = ">= 2"
    }
  }
  required_version = ">= 1"
}
