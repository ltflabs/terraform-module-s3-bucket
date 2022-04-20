variable "SNOWFLAKE_USER_UM" {}

variable "SNOWFLAKE_PASS_UM"{}

variable "SNOWFLAKE_ROLE_UM" {}

variable "SNOWFLAKE_USER_OPS" {}

variable "SNOWFLAKE_PASS_OPS"{}

variable "SNOWFLAKE_ROLE_OPS" {}

variable "SNOWFLAKE_USER_DDL" {}

variable "SNOWFLAKE_PASS_DDL"{}

variable "SNOWFLAKE_ROLE_DDL" {}

variable "AWS_DEFAULT_REGION" {}

variable "SNOWFLAKE_ACCOUNT" {}


variable "database_name" {
  description = "project database name"
  type = string
}

variable "schema_name" {
  description = "project schema name"
  type = string
}

variable "snowpipe_user" {
  description = "project pipe user name"
  type = string
}