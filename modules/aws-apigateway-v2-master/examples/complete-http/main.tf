provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

locals {
  domain_name = "terraform-aws-modules.modules.tf" # trimsuffix(data.aws_route53_zone.this.name, ".")
  subdomain   = "complete-http"
}

###################
# HTTP API Gateway
###################

module "api_gateway" {
  source = "../../"

  name          = "${random_pet.this.id}-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  mutual_tls_authentication = {
    truststore_uri     = "s3://${aws_s3_bucket.truststore.bucket}/${aws_s3_object.truststore.id}"
    truststore_version = aws_s3_object.truststore.version_id
  }

  domain_name                 = local.domain_name
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  authorizers = {
    "cognito" = {
      authorizer_type  = "JWT"
      identity_sources = "$request.header.Authorization"
      name             = "cognito"
      audience         = ["d6a38afd-45d6-4874-d1aa-3c5c558aqcc2"]
      issuer           = "https://${aws_cognito_user_pool.this.endpoint}"
    }
  }

  integrations = {

    "ANY /" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "GET /some-route" = {
      lambda_arn               = module.lambda_function.lambda_function_arn
      payload_format_version   = "2.0"
      authorization_type       = "JWT"
      authorizer_id            = aws_apigatewayv2_authorizer.some_authorizer.id
      throttling_rate_limit    = 80
      throttling_burst_limit   = 40
      detailed_metrics_enabled = true
    }

    "GET /some-route-with-authorizer" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      authorizer_key         = "cognito"
    }

    "GET /some-route-with-authorizer-and-scope" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "JWT"
      authorizer_key         = "cognito"
      authorization_scopes   = "tf/something.relevant.read,tf/something.relevant.write" # Should comply with the resource server configuration part of the cognito user pool
    }

    "GET /some-route-with-authorizer-and-different-scope" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "JWT"
      authorizer_key         = "cognito"
      authorization_scopes   = "tf/something.relevant.write" # Should comply with the resource server configuration part of the cognito user pool
    }

    "POST /start-step-function" = {
      integration_type    = "AWS_PROXY"
      integration_subtype = "StepFunctions-StartExecution"
      credentials_arn     = module.step_function.role_arn

      # Note: jsonencode is used to pass argument as a string
      request_parameters = jsonencode({
        StateMachineArn = module.step_function.state_machine_arn
      })

      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = module.lambda_function.lambda_function_arn
      tls_config = jsonencode({
        server_name_to_verify = local.domain_name
      })

      response_parameters = jsonencode([
        {
          status_code = 500
          mappings = {
            "append:header.header1" = "$context.requestId"
            "overwrite:statuscode"  = "403"
          }
        },
        {
          status_code = 404
          mappings = {
            "append:header.error" = "$stageVariables.environmentId"
          }
        }
      ])
    }

  }

  body = templatefile("api.yaml", {
    example_function_arn = module.lambda_function.lambda_function_arn
  })

  tags = {
    Name = "dev-api-new"
  }
}

######
# ACM
######

data "aws_route53_zone" "this" {
  name = local.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name               = local.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
}

##########
# Route53
##########

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.subdomain
  type    = "A"

  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

#############################
# AWS API Gateway Authorizer
#############################

resource "aws_apigatewayv2_authorizer" "some_authorizer" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = random_pet.this.id

  jwt_configuration {
    audience = ["example"]
    issuer   = "https://${aws_cognito_user_pool.this.endpoint}"
  }
}

########################
# AWS Cognito User Pool
########################

resource "aws_cognito_user_pool" "this" {
  name = "user-pool-${random_pet.this.id}"
}

####################
# AWS Step Function
####################

module "step_function" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "~> 2.0"

  name = random_pet.this.id

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using Pass states",
  "StartAt": "Hello",
  "States": {
    "Hello": {
      "Type": "Pass",
      "Result": "Hello",
      "Next": "World"
    },
    "World": {
      "Type": "Pass",
      "Result": "World",
      "End": true
    }
  }
}
EOF
}

##################
# Extra resources
##################

resource "random_pet" "this" {
  length = 2
}

resource "aws_cloudwatch_log_group" "logs" {
  name = random_pet.this.id
}

#############################################
# Using packaged function from Lambda module
#############################################

locals {
  package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 3.0"

  function_name = "${random_pet.this.id}-lambda"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  publish = true

  create_package         = false
  local_existing_package = local.downloaded

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }
}

###############################################
# S3 bucket and TLS certificate for truststore
###############################################

resource "aws_s3_bucket" "truststore" {
  bucket = "${random_pet.this.id}-truststore"
  #  acl    = "private"
}

resource "aws_s3_object" "truststore" {
  bucket                 = aws_s3_bucket.truststore.bucket
  key                    = "truststore.pem"
  server_side_encryption = "AES256"
  content                = tls_self_signed_cert.example.cert_pem
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  is_ca_certificate = true
  private_key_pem   = tls_private_key.private_key.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "cert_signing",
    "server_auth",
  ]
}
