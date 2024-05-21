variable "newrelic_account_id" {
  type        = number
  description = "New Relic Account Id"
}

variable "newrelic_app_name" {
  type        = string
  description = <<-EOF
    The name of the application to monitor.

    This field is used to name the resources that will be created by Terraform,
    not to filter metrics in New Relic. Use newrelic_fully_qualified_app_name
    for that.
  EOF
}

variable "newrelic_fully_qualified_app_name" {
  type        = string
  description = "The name that the application was registered in New Relic with."
}

variable "service_healthcheck_url" {
  type        = string
  default     = null
  description = <<-EOF
    The URL of the service to be used for synthetics monitoring.

    If undefined, no synthetics monitoring for the health check will be created.
  EOF
}

variable "alert_health_check_threshold" {
  type        = number
  default     = 2
  description = "Number of failed health checks before the alert is triggered"
}

variable "alert_health_check_duration" {
  type        = number
  default     = 300
  description = "How long the synthetics monitor check must fail before an alert is triggered (in seconds)"
}

variable "runbook_url" {
  type        = string
  default     = null
  description = "URL where the runbook is located."
}

variable "enable_dashboard" {
  type        = bool
  default     = false
  description = "True if creating a custom dashboard is desired; false otherwise."
}

variable "dashboard_permissions" {
  type        = string
  default     = "public_read_only"
  description = <<-EOF
    Determines who can see the dashboard in an account.

    See https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/one_dashboard#permissions
  EOF
}

variable "enable_pagerduty_notifications" {
  type        = bool
  default     = false
  description = "True if PagerDuty notifications are desired; false otherwise."
}

variable "pagerduty_service_key" {
  type        = string
  default     = null
  description = "Integration key for the PagerDuty Service"
}

variable "alert_error_rate_enable" {
  type        = bool
  default     = false
  description = "Enable or disable error rate alert"
}

variable "alert_error_rate_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is triggered (in seconds)"
}

variable "alert_error_rate_threshold" {
  type        = number
  default     = 10
  description = "Error threshold (in percentage)"
}

variable "response_status_variable_name" {
  type        = string
  default     = "response.status"
  description = <<-EOT
    Name of the variable containing the response status in a transaction.

    Different New Relic agents seem to use different names for the variable
    containing the response status. `response.status` and `httpResponseCode`
    seem to be the names used by most agents. Set this variable to override
    the default value.
  EOT
}

variable "status_code_alerts" {
  type = list(object({
    name                  = string
    status_code_pattern   = string
    urgent                = bool
    duration              = number
    threshold             = number
    extra_nrql_conditions = optional(string)
  }))

  nullable = true

  description = <<-EOT
    List of alerts to be created based on status codes.
    `name`: name of the alert
    `status_code_pattern`: actual value (or pattern) of the response code used to check for the status code.
    For instance '400' or '4%'
    `urgent`: if true, urgent policy will be used
    `duration`: the number of seconds that the threshold needs to be exceeded before triggering the alert.
    `threshold`: maximum percentage of requests that are allowed to result in the specified status code before the alert triggers.
    `extra_nrql_conditions`: extra filters to add to the alert (optional)
  EOT
}

variable "alert_high_latency_urgent_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is triggered (in seconds)"
}

variable "alert_high_latency_urgent_threshold" {
  type        = number
  default     = 1000
  description = "Latency threshold (in milliseconds)"
}

variable "alert_high_latency_non_urgent_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is triggered (in seconds)"
}

variable "alert_high_latency_non_urgent_threshold" {
  type        = number
  default     = 1000
  description = "Latency threshold (in milliseconds)"
}

variable "create_default_slos" {
  type        = bool
  default     = false
  description = "If true, two SLOs (latency and availability) will be created"
}

variable "latency_slo_target" {
  type        = number
  default     = 95.00
  description = "Target value for latency SLO"
}

variable "latency_slo_duration_threshold" {
  type        = number
  description = "Duration threshold for the latency SLO (in seconds)"
}

variable "availability_slo_target" {
  type        = number
  default     = 99.00
  description = "Target value for availability SLO"
}
