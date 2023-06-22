variable "project_name"{
    type = string
    description = "MongoDB atlas project id"
}
variable "atlas_role_id"{
    type = string
    description = "MongoDB atlas role id"
}

variable "aws_kms_key_arn"{
    type = string
    description = "AWS KMS Key arn"
}

variable "atlas_aws_account_arn"{
    type = string
    description = "Atlas AWS account arn"
}

variable "atlas_assumed_role_external_id"{
    type = string
    description = "Atlas assumed role external id"
}
