terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = ">= 3"
    }
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = ">= 1.9.3"
    }
  }
  required_version = ">= 0.13"
}
