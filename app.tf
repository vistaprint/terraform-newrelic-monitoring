data "newrelic_entity" "app" {
  name = var.newrelic_fully_qualified_app_name
  type = "APPLICATION"
}
