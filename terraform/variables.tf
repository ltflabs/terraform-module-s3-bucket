variable "SNOWFLAKE_USER_UM" {
    description = "user for management of users"
    type        = string    
}

variable "SNOWFLAKE_ROLE_UM" {
    description = "user for management of users"
    type        = string    
}

variable "SNOWFLAKE_USER_OPS" {
    description = "user for management of users"
    type        = string    
}

variable "SNOWFLAKE_ROLE_OPS" {
    description = "user for management of users"
    type        = string    
}

variable "SNOWFLAKE_USER_DDL" {
    description = "user for management of users"
    type        = string    
}

variable "SNOWFLAKE_ROLE_DDL" {
    description = "user for management of users"
    type        = string    
}

variable "SNOWFLAKE_STORAGE_INT" {
    description = "user for management of users"
    type        = string    
}

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