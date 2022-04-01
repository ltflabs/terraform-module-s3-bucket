terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_default_region

}

locals {
  namespace = "s3_testing"
}



module "this_bucket" {

  bucket_prefix = local.namespace

}

resource aws_sns_topic "project_sns_topic" {
  name_prefix = local.namespace
}


data snowflake_system_get_aws_sns_iam_policy  snowflake_sns {
    aws_sns_topic_arn = aws_sns_topic.project_sns_topic.arn

}


############################################################
# SNS Policy Build Start
############################################################

data "aws_iam_policy_document" "s3_sns_topic_policy" {

  statement = {
        sid = "_default_s3_publish"
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
            test = "ArnLike"
            values = [module.this_bucket.arn]
            variable = "aws:SourceArn"
        }
      }
}


data "aws_iam_policy_document" "sns_topic_policy" {

  statement = {
        sid = "_default_sns_subscribe"
        effect = "Allow"
        actions = [
          "SNS:Subscribe"
        ]
        principal = {
          type = "AWS"
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

############################################################
# SNS Policy Build Start
############################################################



# Attach Policy

resource "aws_sns_topic_policy" "attach_sns_policy" {
  arn = aws_sns_topic.project_sns_topic.arn

  policy = data.aws_iam_policy_document.combined_sns_policy.json
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn = aws_sns_topic.topic.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectCreated:Put"]
  }
}
