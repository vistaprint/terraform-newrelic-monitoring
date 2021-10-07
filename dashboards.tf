resource "newrelic_one_dashboard" "dashboard" {
  count = var.enable_dashboard ? 1 : 0

  account_id = var.newrelic_account_id
  name       = "${var.newrelic_app_name} Dashboard"

  permissions = var.dashboard_permissions

  page {
    name = "${var.newrelic_app_name} Dashboard"

    widget_line {
      title  = "Latency (seconds)"
      row    = 1
      column = 1
      width  = 12
      nrql_query {
        query = <<-EOF
          SELECT
              AVERAGE(duration),
              PERCENTILE(duration, 50, 90, 99, 99.9)
          FROM Transaction
          WHERE appName = '${var.newrelic_fully_qualified_app_name}'
            AND request.uri != '/'
            AND request.uri != '/favicon.ico'
            AND request.uri NOT LIKE '/swagger%'
            AND request.uri != '/metrics'
          TIMESERIES 5 minutes
          SINCE 24 hours ago
          EOF
      }
    }

    widget_line {
      title  = "Traffic (requests per minute)"
      row    = 2
      column = 1
      width  = 5
      nrql_query {
        query = <<-EOF
          SELECT rate(count(*), 1 minute) AS 'Requests per minute'
          FROM Transaction
          WHERE appName = '${var.newrelic_fully_qualified_app_name}'
          TIMESERIES 5 minutes
          SINCE 24 hours ago
          EXTRAPOLATE
          EOF
      }
    }

    widget_line {
      title  = "Errors"
      row    = 2
      column = 6
      width  = 7
      nrql_query {
        query = <<-EOF
          SELECT
              percentage(count(*), WHERE error is true) AS 'Total error rate',
              percentage(count(*), WHERE ${var.response_status_variable_name} LIKE '5%') AS '5xx error rate',
              percentage(count(*), WHERE ${var.response_status_variable_name} LIKE '4%') AS '4xx error rate'
          FROM Transaction
          WHERE appName = '${var.newrelic_fully_qualified_app_name}'
          TIMESERIES 5 minutes
          SINCE 24 hours ago
          EXTRAPOLATE
          EOF
      }
    }
  }
}
