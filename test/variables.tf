variable "newrelic_account_id" {
  type = number
}

variable "newrelic_region" {
  type    = string
  default = "US"
}

variable "newrelic_api_key" {
  type = string
}

variable "newrelic_admin_api_key" {
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

variable "pagerduty_user_email" {
  type        = string
  description = "Pagerduty's user e-mail. This user must belong to 'pagerduty_team_name' and have Manager permissions."
}

variable "pagerduty_team_name" {
  type = string
}

variable "pagerduty_api_token" {
  type = string
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
