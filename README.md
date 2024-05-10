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

