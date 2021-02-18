# terraform-newrelic-monitoring

This [Terraform](https://www.terraform.io) module creates [New Relic](https://newrelic.com) alerts and a dashboard to monitor an application. It also allows for sending notifications to [VictorOps](https://victorops.com).

## Example Usage

```hcl
provider "newrelic" {
  account_id    = Your New Relic account id
  api_key       = "Your New Relic API key"
  admin_api_key = "Your New Relic admin API key"
  region        = "Your New Relic account region (US or EU)"
}

module "newrelic_monitoring" {
  source  = "vistaprint/monitoring/newrelic"
  version = "1.0.0"

  newrelic_account_id = Your New Relic account id

  newrelic_app_name                 = "Your app name"
  newrelic_fully_qualified_app_name = "Team/PRD/App"
  service_healthcheck_url           = "https://your-service-url.com"

  enable_victorops_notifications   = true
  victorops_api_key                = "Your VictorOps API key"
  victorops_urgent_routing_key     = "your-team-urgent"
  victorops_non_urgent_routing_key = "your-team-non-urgent"
}
```

See `variables.tf` for more information on the input variables that the module accepts. For instance, the default values for an alert's duration and threshold can be overridden. The following example shows how to do so:

```hcl
module "newrelic_monitoring" {
  source  = "vistaprint/monitoring/newrelic"
  version = "1.0.0"

  # some fields ommitted (see previous example)

  alert_error_rate_5xx_duration  = 600 # seconds
  alert_error_rate_5xx_threshold = 5  # percentage
}
```
