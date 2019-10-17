resource "newrelic_dashboard" "dashboard" {
  count = var.enable_dashboard ? 1 : 0

  title = "${var.newrelic_app_name} Dashboard"

  widget {
    title         = "Latency (seconds)"
    row           = 1
    column        = 1
    width         = 3
    visualization = "line_chart"
    nrql          = <<-EOF
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

  widget {
    title         = "Traffic (requests per minute)"
    row           = 2
    column        = 1
    width         = 1
    visualization = "line_chart"
    nrql          = <<-EOF
        SELECT rate(count(*), 1 minute) AS 'Requests per minute'
        FROM Transaction 
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        TIMESERIES 5 minutes
        SINCE 24 hours ago
        EXTRAPOLATE
        EOF
  }

  widget {
    title         = "Errors"
    row           = 2
    column        = 2
    width         = 2
    visualization = "line_chart"
    nrql          = <<-EOF
        SELECT 
            percentage(count(*), WHERE error is true) AS 'Total error rate',
            percentage(count(*), WHERE response.status LIKE '5%') AS '5xx error rate',
            percentage(count(*), WHERE response.status LIKE '4%') AS '4xx error rate'
        FROM Transaction 
        WHERE appName = '${var.newrelic_fully_qualified_app_name}'
        TIMESERIES 5 minutes
        SINCE 24 hours ago
        EXTRAPOLATE
        EOF
  }
}
