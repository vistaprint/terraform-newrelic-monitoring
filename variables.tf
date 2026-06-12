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
  default     = 1
  description = "Number of failed health checks before the alert is triggered"
}

variable "alert_health_check_duration" {
  type        = number
  default     = 300
  description = "How long the synthetics monitor check must fail before an alert is triggered (in seconds)"
}

variable "alert_health_check_fill_option" {
  type        = string
  default     = null
  description = "Fill option for health check alert to handle gaps in data. Options: 'none', 'last_value', 'static'"
}

variable "alert_health_check_fill_value" {
  type        = number
  default     = null
  description = "Fill value when alert_health_check_fill_option is 'static'"
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

variable "alert_error_rate_fill_option" {
  type        = string
  default     = null
  description = "Fill option for error rate alert to handle gaps in data. Options: 'none', 'last_value', 'static'"
}

variable "alert_error_rate_fill_value" {
  type        = number
  default     = null
  description = "Fill value when alert_error_rate_fill_option is 'static'"
}

variable "alert_error_rate_type" {
  type        = string
  default     = "static"
  description = "Type of the error rate alert condition. Options: 'static', 'baseline'"

  validation {
    condition     = contains(["static", "baseline"], var.alert_error_rate_type)
    error_message = "alert_error_rate_type must be 'static' or 'baseline'."
  }
}

variable "alert_error_rate_baseline_direction" {
  type        = string
  default     = null
  description = "Baseline direction for the error rate alert when alert_error_rate_type is 'baseline'. Options: 'lower_only', 'upper_and_lower', 'upper_only'"

  validation {
    condition     = var.alert_error_rate_baseline_direction == null || contains(["lower_only", "upper_and_lower", "upper_only"], var.alert_error_rate_baseline_direction)
    error_message = "alert_error_rate_baseline_direction must be 'lower_only', 'upper_and_lower', or 'upper_only'."
  }
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
    fill_option           = optional(string)
    fill_value            = optional(number)
    type                  = optional(string, "static")
    baseline_direction    = optional(string)
  }))

  nullable = true

  validation {
    condition     = var.status_code_alerts == null || alltrue([for alert in var.status_code_alerts : contains(["static", "baseline"], alert.type)])
    error_message = "Each status_code_alert 'type' must be 'static' or 'baseline'."
  }

  validation {
    condition     = var.status_code_alerts == null || alltrue([for alert in var.status_code_alerts : alert.baseline_direction == null || contains(["lower_only", "upper_and_lower", "upper_only"], alert.baseline_direction)])
    error_message = "Each status_code_alert 'baseline_direction' must be 'lower_only', 'upper_and_lower', or 'upper_only'."
  }

  description = <<-EOT
    List of alerts to be created based on status codes.
    `name`: name of the alert
    `status_code_pattern`: actual value (or pattern) of the response code used to check for the status code.
    For instance '400' or '4%'
    `urgent`: if true, urgent policy will be used
    `duration`: the number of seconds that the threshold needs to be exceeded before triggering the alert.
    `threshold`: maximum percentage of requests that are allowed to result in the specified status code before the alert triggers.
    `extra_nrql_conditions`: extra filters to add to the alert (optional)
    `fill_option`: fill option for handling gaps in data (optional). Options: "none", "last_value", "static"
    `fill_value`: fill value when fill_option is "static" (optional, defaults to 0)
    `type`: type of the alert condition (optional, defaults to "static"). Options: "static", "baseline"
    `baseline_direction`: baseline direction when type is "baseline" (optional). Options: "lower_only", "upper_and_lower", "upper_only"
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

variable "alert_high_latency_urgent_fill_option" {
  type        = string
  default     = null
  description = "Fill option for high latency urgent alert to handle gaps in data. Options: 'none', 'last_value', 'static'"
}

variable "alert_high_latency_urgent_fill_value" {
  type        = number
  default     = null
  description = "Fill value when alert_high_latency_urgent_fill_option is 'static'"
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

variable "alert_high_latency_non_urgent_fill_option" {
  type        = string
  default     = null
  description = "Fill option for high latency non-urgent alert to handle gaps in data. Options: 'none', 'last_value', 'static'"
}

variable "alert_high_latency_non_urgent_fill_value" {
  type        = number
  default     = null
  description = "Fill value when alert_high_latency_non_urgent_fill_option is 'static'"
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
