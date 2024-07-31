resource "aws_iam_role" "scheduler" {
  name = "instance-scheduler-assume-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "scheduler.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "scheduler_execution" {
  name        = "scheduler-execution-policy"
  description = "Instance scheduler exection IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler_execution.arn
}

resource "aws_iam_role_policy_attachment" "SSMPolicy" {
  role       = aws_iam_role.scheduler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

# Documents

resource "aws_ssm_document" "start_document" {
  name            = "start_instance_document"
  document_format = "YAML"
  document_type   = "Automation"
  content         = file("automation-start-runbook.yaml")
}

resource "aws_ssm_document" "stop_document" {
  name            = "stop_instance_document"
  document_format = "YAML"
  document_type   = "Automation"
  content         = file("automation-stop-runbook.yaml")
}

# Scheduler

resource "aws_scheduler_schedule" "start_instance" {
  name       = "start_instance_scheduler"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 7 * * ? *)"
  schedule_expression_timezone = "Europe/Madrid"

  state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      DocumentName = aws_ssm_document.start_document.name
    })
  }
}

resource "aws_scheduler_schedule" "stop_instance" {
  name       = "stop_instance_scheduler"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = "cron(0 18 * * ? *)"
  schedule_expression_timezone = "Europe/Madrid"

  state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      DocumentName = aws_ssm_document.stop_document.name
    })
  }
}
