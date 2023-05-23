resource "newrelic_service_level" "latency" {
  count = var.create_default_slos == true ? 1 : 0

  guid        = data.newrelic_entity.app.guid
  name        = "Latency"
  description = "Proportion of requests that are served faster than a threshold."

  events {
    account_id = var.newrelic_account_id
    valid_events {
      from  = "Transaction"
      where = "entityGuid = '${data.newrelic_entity.app.guid}' AND (transactionType = 'Web')"
    }
    good_events {
      from  = "Transaction"
      where = "entityGuid = '${data.newrelic_entity.app.guid}' AND (transactionType = 'Web') AND duration < ${var.latency_slo_duration_threshold}"
    }
  }

  objective {
    target = var.latency_slo_target
    time_window {
      rolling {
        count = 7
        unit  = "DAY"
      }
    }
  }
}

resource "newrelic_service_level" "availability" {
  count = var.create_default_slos == true ? 1 : 0

  guid        = data.newrelic_entity.app.guid
  name        = "Availability"
  description = "Proportion of requests that are served without errors."

  events {
    account_id = var.newrelic_account_id
    valid_events {
      from  = "Transaction"
      where = "entityGuid = '${data.newrelic_entity.app.guid}'"
    }
    bad_events {
      from  = "TransactionError"
      where = "entityGuid = '${data.newrelic_entity.app.guid}' AND error.expected IS FALSE"
    }
  }

  objective {
    target = var.availability_slo_target
    time_window {
      rolling {
        count = 7
        unit  = "DAY"
      }
    }
  }
}
