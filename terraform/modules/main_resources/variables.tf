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

variable "SNOWFLAKE_STORAGE_INT" {
  description = "Snowflake int user"
  type        = string
}
