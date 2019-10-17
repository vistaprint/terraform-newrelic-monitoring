variable "newrelic_api_key" {
  type = string
}

variable "newrelic_app_name" {
  type = string
}

variable "newrelic_fully_qualified_app_name" {
  type = string
}

variable "service_healthcheck_url" {
  type    = string
  default = null
}

variable "runbook_url" {
  type    = string
  default = null
}

variable "victorops_api_key" {
  type    = string
  default = null
}

variable "victorops_urgent_routing_key" {
  type    = string
  default = null
}

variable "victorops_non_urgent_routing_key" {
  type    = string
  default = null
}
