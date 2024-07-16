resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.name

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          "height": 6,
          "width": 6,
          "y": 0,
          "x": 0,
          "type": "metric",
          "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
              ["AWS/RDS", "CPUUtilization", { "stat": "Maximum", "label": "Top 10 RDS Instances", "id": "q1" }]
            ],
            "region": var.region,
            "title": "Top 10 RDS instances by highest CPU utilization",
            "yAxis": {
              "left": {
                "label": "Percent",
                "showUnits": false
              }
            },
            "stat": "Average",
            "period": 300
          }
        },
        {
          "height": 6,
          "width": 6,
          "y": 0,
          "x": 6,
          "type": "metric",
          "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
              ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "${var.environment}-rds-sql-server", { "period": 60 }]
            ],
            "region": var.region,
            "title": "RDS - FreeableMemory"
          }
        },
        {
          "height": 6,
          "width": 6,
          "y": 0,
          "x": 12,
          "type": "metric",
          "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
              ["AWS/RDS", "DBLoad", "DBInstanceIdentifier", "${var.environment}-rds-sql-server", { "period": 60 }]
            ],
            "region": var.region,
            "title": "RDS - DBLoad"
          }
        },
        {
          "height": 6,
          "width": 24,
          "y": 18,
          "x": 0,
          "type": "log",
          "properties": {
            "query": "SOURCE '/aws/containerinsights/${var.environment}-eks/application' | fields @timestamp, kubernetes.namespace_name, @message, @logStream, @log\n| sort @timestamp desc\n| limit 10000",
            "region": var.region,
            "stacked": false,
            "view": "table",
            "title": "EKS Applications - Log group: /aws/containerinsights/${var.environment}-eks/application"
          }
        },
        {
          "height": 6,
          "width": 6,
          "y": 0,
          "x": 18,
          "type": "metric",
          "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
              ["AWS/RDS", "ReadThroughput", "DBInstanceIdentifier", "${var.environment}-rds-sql-server", { "period": 60 }],
              [".", "WriteThroughput", ".", ".", { "period": 60 }]
            ],
            "region": var.region,
            "title": "RDS - ReadThroughput, WriteThroughput"
          }
        },
        {
          "height": 6,
          "width": 6,
          "y": 6,
          "x": 0,
          "type": "metric",
          "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
              ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "${var.environment}-rds-sql-server", { "period": 60 }],
              [".", "WriteLatency", ".", ".", { "period": 60 }]
            ],
            "region": var.region,
            "title": "RDS - ReadLatency, WriteLatency"
          }
        },
        {
          "height": 6,
          "width": 6,
          "y": 6,
          "x": 6,
          "type": "metric",
          "properties": {
            "view": "timeSeries",
            "stacked": false,
            "metrics": [
              ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", "${var.environment}-rds-sql-server", { "period": 60 }],
              [".", "WriteIOPS", ".", ".", { "period": 60 }]
            ],
            "region": var.region,
            "title": "RDS - ReadIOPS, WriteIOPS"
          }
        }
      ],
      flatten([
        for namespace in var.namespaces :
        [
          for app in var.applications :
          {
            "height": 6,
            "width": 6,
            "y": floor((index(var.namespaces, namespace) * length(var.applications) + index(var.applications, app)) / 4) * 6,
            "x": ((index(var.namespaces, namespace) * length(var.applications) + index(var.applications, app)) % 4) * 6,
            "type": "metric",
            "properties": {
              "view": "timeSeries",
              "stacked": false,
              "metrics": [
                ["ContainerInsights", "pod_cpu_utilization", "PodName", app, "ClusterName", "${var.environment}-eks", "Namespace", namespace]
              ],
              "region": var.region,
              "title": "${namespace} - ${app} CPU Utilization"
            }
          }
        ]
      ])
    )
  })
}
