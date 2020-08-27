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

variable "enable_victorops_notifications" {
  type        = bool
  default     = false
  description = "True if VictorOps notifications are desired; false otherwise."
}

variable "victorops_api_key" {
  type        = string
  default     = null
  description = "API key for VictorOps"
}

variable "victorops_urgent_routing_key" {
  type        = string
  default     = null
  description = "Routing key where urgent notifications will be sent."
}

variable "victorops_non_urgent_routing_key" {
  type        = string
  default     = null
  description = "Routing key where non-urgent notifications will be sent."
}

variable "alert_error_rate_enable" {
  type        = bool
  default     = false
  description = "Enable or disable error rate alert"
}

variable "alert_error_rate_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is raised (in seconds)"
}

variable "alert_error_rate_threshold" {
  type        = number
  default     = 10
  description = "Error threshold (in percentage)"
}

variable "alert_error_rate_5xx_enable" {
  type        = bool
  default     = true
  description = "Enable or disable 5xx error rate alert"
}

variable "alert_error_rate_5xx_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is raised (in seconds)"
}

variable "alert_error_rate_5xx_threshold" {
  type        = number
  default     = 10
  description = "Error threshold (in percentage)"
}

variable "alert_error_rate_4xx_enable" {
  type        = bool
  default     = true
  description = "Enable or disable 4xx error rate alert"
}

variable "alert_error_rate_4xx_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is raised (in seconds)"
}

variable "alert_error_rate_4xx_threshold" {
  type        = number
  default     = 30
  description = "Error threshold (in percentage)"
}

variable "alert_error_rate_4xx_conditions" {
  type        = string
  default     = ""
  description = "WHERE conditions for alert on 4xx errors (must start with AND)"
}

variable "alert_high_latency_urgent_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is raised (in seconds)"
}

variable "alert_high_latency_urgent_threshold" {
  type        = number
  default     = 1000
  description = "Latency threshold (in milliseconds)"
}

variable "alert_high_latency_non_urgent_duration" {
  type        = number
  default     = 300
  description = "How long the error threshold must be exceeded for before an alert is raised (in seconds)"
}

variable "alert_high_latency_non_urgent_threshold" {
  type        = number
  default     = 1000
  description = "Latency threshold (in milliseconds)"
}

variable "response_status_variable_name" {
  type        = string
  default     = "response.status"
  description = <<-EOF
    Name of the variable containing the response status in a transaction.

    Different New Relic agents seem to use different names for the variable
    containing the response status. `response.status` and `httpResponseCode`
    seem to be the names used by most agents. Set this variable to override
    the default value.
  EOF
}
