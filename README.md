# terraform-newrelic-monitoring

This [Terraform](https://www.terraform.io) module creates [New Relic](https://newrelic.com) alerts and a dashboard to monitor an application. It also allows for sending notifications to [PagerDuty](https://www.pagerduty.com/).

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
  version = "2.0.0"

  newrelic_account_id = Your New Relic account id

  newrelic_app_name                 = "Your app name"
  newrelic_fully_qualified_app_name = "Team/PRD/App"
  service_healthcheck_url           = "https://your-service-url.com"
}
```

See [variables.tf](./variables.tf) for more information on the input variables that the module accepts. For instance, the default values for an alert's duration and threshold can be overridden. The following example shows how to do so:

```hcl
module "newrelic_monitoring" {
  source  = "vistaprint/monitoring/newrelic"
  version = "1.0.0"

  # some fields ommitted (see previous example)

  alert_error_rate_5xx_duration  = 600 # seconds
  alert_error_rate_5xx_threshold = 5  # percentage
}
```

## Enabling Integration with PagerDuty

To integrate your New Relic alerts with PagerDuty add the following lines to the module configuration:

```hcl
enable_pagerduty_notifications = true
pagerduty_service_key          = "The New Relic integration key for your service in PagerDuty"
```

You can obtain the integration key for your service with Terraform using a resource named `pagerduty_service_integration`.

## Creating Default SLOs

New Relic supports the creation of [service levels](https://docs.newrelic.com/docs/service-level-management/intro-slm/) for applications. This terraform module allows for creating two SLOs &ndash; one measuring request latency and the other measuring application availability. The SLOs use a default rolling time window spanning seven days. To create the SLOs, set the following variable:

```hcl
create_default_slos = true
```

Some parameters for the SLOs can be fine-tuned (see [variables.tf](./variables.tf) for more details). For instance, you can use the following snippet to specify that the latency duration should not exceed 100 ms with a target value of 99.99%.

```hcl
latency_slo_target = 99.99
latency_slo_duration_threshold = 0.1
```

For more details about these parameters, please check the [official documentation](https://docs.newrelic.com/docs/service-level-management/intro-slm/).
