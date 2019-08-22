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

variable "service_url" {
  type        = string
  description = "The URL of the service to be used for synthetics monitoring."
}

variable "runbook_url" {
  type        = string
  default     = null
  description = "URL where the runbook is located."
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
