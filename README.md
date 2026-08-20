# AWS SNS Topic Terraform module

Terraform module which creates SNS resources on AWS
## Usage

### Simple Topic

```hcl
module "sns_topic" {
  source  = "git::https://github.com/kloia/platform-modules//aws-sns?ref=main"

  name  = "simple"

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Topic w/ SQS Subscription

```hcl
module "sns_topic" {
  source  = "git::https://github.com/kloia/platform-modules//aws-sns?ref=main"

  name  = "pub-sub"

  topic_policy_statements = {
    pub = {
      actions = ["sns:Publish"]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::66666666666:role/publisher"]
      }]
    },

    sub = {
      actions = [
        "sns:Subscribe",
        "sns:Receive",
      ]

      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]

      conditions = [{
        test     = "StringLike"
        variable = "sns:Endpoint"
        values   = ["arn:aws:sqs:eu-west-1:11111111111:subscriber"]
      }]
    }
  }

  subscriptions = {
    sqs = {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:eu-west-1:11111111111:subscriber"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Subscription with a Secret-Backed Endpoint

For endpoints that embed a credential (e.g. an API key in the URL, as some
webhook-style integrations require), set `endpoint_secret_ssm_path` +
`endpoint_template` instead of a literal `endpoint`. The value is read from
SSM Parameter Store (SecureString) at apply time via a `data` source, so it
never needs to be known at Terragrunt/config-generation time and is treated
as sensitive in plan output. Subscriptions that don't set
`endpoint_secret_ssm_path` are unaffected and keep using a literal `endpoint`
as before.

```hcl
module "sns_topic" {
  source = "../.."

  name = "example-alerts"

  subscriptions = {
    webhook = {
      protocol                 = "https"
      endpoint_secret_ssm_path = "/example/prod/webhook/api_key"
      endpoint_template        = "https://example.com/notify?apiKey=%s"
    }
  }
}
```

### FIFO Topic w/ FIFO SQS Subscription

```hcl
module "sns_topic" {
  source  = "git::https://github.com/kloia/platform-modules//aws-sns?ref=main"

  name  = "my-topic"

  # SQS queue must be FIFO as well
  fifo_topic                  = true
  content_based_deduplication = true

  topic_policy_statements = {
    pub = {
      actions = ["sns:Publish"]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::66666666666:role/publisher"]
      }]
    },

    sub = {
      actions = [
        "sns:Subscribe",
        "sns:Receive",
      ]

      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]

      conditions = [{
        test     = "StringLike"
        variable = "sns:Endpoint"
        values   = ["arn:aws:sqs:eu-west-1:11111111111:subscriber.fifo"]
      }]
    }
  }

  subscriptions = {
    sqs = {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:eu-west-1:11111111111:subscriber.fifo"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

