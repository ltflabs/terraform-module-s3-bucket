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

module "main_resources" {
  source = "./modules/mainresources"
}


#####################################################
# AWS 
#####################################################
resource "aws_iam_role" "this_bucket_access_role" {
  name = module.main_resources.this_bucket_role_access_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = module.main_resources.snowflake_storage_integration.integration_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" : module.main_resources.snowflake_storage_integration.integration_external_id
          }
        }
      }
    ]
  })
}

#####################################################
# SnowFlake 
#####################################################

data "snowflake_database" "this_database" {
  provider = snowflake.snowflake_ops

  name = var.database_name
}

############### table section ###############

resource "snowflake_table" "this_billing_table" {
  provider = snowflake.snowflake_ops

  database = snowflake_database.this_database.name
  schema   = var.schema_name
  name     = "aws_billing"
  comment  = "AWS billing data."

  column {
    name    = "data"
    type    = "VARIANT"
    comment = "na_corp_raw billing"
  }

}

resource "snowflake_table_grant" "grant_insert_select_this_billing_table" {
  provider = snowflake.snowflake_ops

  database   = snowflake_database.this_database.name
  schema     = var.schema_name
  table_name = snowflake_table.this_billing_table.name

  privilege = "INSERT , SELECT"
  roles     = [var.SNOWFLAKE_ROLE_DDL]
}


resource "snowflake_table_grant" "grant_usage_read_this_billing_table" {
  provider = snowflake.snowflake_ops

  database   = snowflake_database.this_database.name
  schema     = var.schema_name
  table_name = snowflake_table.this_billing_table.name

  privilege = "USAGE , READ"
  roles     = [var.SNOWFLAKE_ROLE_DDL]
}



############### table end ##################

resource "snowflake_stage" "aws_billing_stage" {
  provider = snowflake.snowflake_ops

  name                = "na_corp_aws_billing"
  url                 = "s3://${module.main_resources.this_bucket_role_access_id}"
  database            = snowflake_database.this_database.name
  schema              = var.schema_name
  storage_integration = module.main_resources.snowflake_storage_integration.integration_name
}

resource "snowflake_stage_grant" "grant_usage_read_stage" {
  provider = snowflake.snowflake_ops

  database_name = snowflake_stage.example_stage.database
  schema_name   = snowflake_stage.example_stage.schema
  privilege     = "USAGE , READ"

  roles      = [var.SNOWFLAKE_ROLE_DDL]
  stage_name = snowflake_stage.example_stage.name
}

resource "snowflake_pipe" "aws_billing_pipe" {
  provider = snowflake.snowflake_ops

  database = snowflake_database.this_database.name
  schema   = var.schema_name
  name     = "aws_billing_pipe"

  comment = "pipe for aws billing data"

  copy_statement = "copy into ${snowflake_table.this_billing_table.name} from ${snowflake_stage.aws_billing_stage.name}"
  auto_ingest    = true

  aws_sns_topic_arn = module.main_resources.project_sns_topic_arn
  file_format       = "JSON"
  owner             = var.SNOWFLAKE_ROLE_DDL
}
