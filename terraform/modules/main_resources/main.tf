terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.20.0"
    }
  }
}

#####################################################
# Globals 
#####################################################

provider "aws" {
  region = var.aws_default_region
}

provider "snowflake" {
  alias = "snowflake_user_mangt"

  username = var.SNOWFLAKE_USER_UM
  role     = var.SNOWFLAKE_ROLE_UM
}

provider "snowflake" {
  alias = "snowflake_ops"

  username = var.SNOWFLAKE_USER_OPS
  role     = var.SNOWFLAKE_ROLE_OPS
}

provider "snowflake" {
  alias = "snowflake_ddl"

  username = var.SNOWFLAKE_USER_DDL
  role     = var.SNOWFLAKE_ROLE_DDL
}


locals {
  namespace = "snowflake_poc"
}

#####################################################
# SnowFlake 
#####################################################

#get ci schema

resource "snowflake_storage_integration" "integration" {
  provider = snowflake.snowflake_user_mangt

  name                      = var.SNOWFLAKE_STORAGE_INT
  comment                   = "A storage integration for billing data."
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  storage_allowed_locations = ["${aws_s3_bucket.this_bucket.id}"]
  storage_aws_role_arn      = aws_iam_role.this_bucket_access_role.arn

  enabled = true
}


#####################################################
# AWS 
#####################################################
# AWS Resources

resource "aws_s3_bucket" "this_bucket" {
  bucket_prefix = local.namespace
}

resource "aws_sns_topic" "project_sns_topic" {
  name_prefix = local.namespace
}

# IAM Permissions

resource "aws_iam_policy" "this_bucket_access_policy" {
  name_prefix = local.namespace
  path        = "/"
  description = "POC policy for snowflake bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.this_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "this_bucket_access_role" {
  name_prefix = local.namespace

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "this_bucket_access_policy_attatchment" {
  role       = aws_iam_role.this_bucket_access_role
  policy_arn = aws_iam_policy.this_bucket_access_policy
}


# SNS Policy Build Start

data "snowflake_system_get_aws_sns_iam_policy" "snowflake_sns" {
  provider = snowflake.snowflake_user_mangt

  aws_sns_topic_arn = aws_sns_topic.project_sns_topic.arn

}

data "aws_iam_policy_document" "s3_sns_topic_policy" {

  statement = {
    sid    = "_default_s3_publish"
    effect = "Allow"
    actions = [
      "SNS:Publish"
    ]
    principal = {
      service = "s3.amazonaws.com"
    }
    resources = [
      aws_sns_topic.project_sns_topic.arn
    ]
    condition = {
      test     = "ArnLike"
      values   = [module.this_bucket.arn]
      variable = "aws:SourceArn"
    }
  }
}


data "aws_iam_policy_document" "sns_topic_policy" {

  statement = {
    sid    = "_default_sns_subscribe"
    effect = "Allow"
    actions = [
      "SNS:Subscribe"
    ]
    principal = {
      type        = "AWS"
      identifiers = snowflake_system_get_aws_sns_iam_policy.aws_sns_topic_arn
    }
    resources = [
      aws_sns_topic.project_sns_topic.arn
    ]
  }
}

data "aws_iam_policy_document" "combined_sns_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.s3_sns_topic_policy.json,
    data.aws_iam_policy_document.sns_topic_policy.json
  ]
}


resource "aws_sns_topic_policy" "attach_sns_policy" {
  arn = aws_sns_topic.project_sns_topic.arn

  policy = data.aws_iam_policy_document.combined_sns_policy.json
}


# Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn = aws_sns_topic.topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectCreated:Put"]
  }
}
