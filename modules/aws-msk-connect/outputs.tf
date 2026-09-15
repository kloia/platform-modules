output "custom_plugins" {
  description = "Map of created custom plugins keyed by input key, exposing the ARN, latest revision and state."
  value = {
    for name, plugin in aws_mskconnect_custom_plugin.this : name => {
      arn             = plugin.arn
      latest_revision = plugin.latest_revision
      state           = plugin.state
    }
  }
}

output "worker_configurations" {
  description = "Map of created worker configurations keyed by input key, exposing the ARN and latest revision."
  value = {
    for name, wc in aws_mskconnect_worker_configuration.this : name => {
      arn             = wc.arn
      latest_revision = wc.latest_revision
    }
  }
}

output "connectors" {
  description = "Map of created connectors keyed by input key, exposing the ARN and current version."
  value = {
    for name, connector in aws_mskconnect_connector.this : name => {
      arn     = connector.arn
      version = connector.version
    }
  }
}
