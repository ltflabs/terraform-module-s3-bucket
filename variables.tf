variable "service_name" {
    description = "Control for creating bucket"
    type = string
    default = ""
}

variable "create_bucket" {
    description = "Control for creating bucket"
    type = bool
    default = true
}

variable "bucket_name"{
    description = "bucket name to create"
    type = string
    default = ""
}

variable "accountId"{
    description = "Cloud AccountID"
    type = string
    default = ""
}

variable "put_bucket_policy"{
    description = "control to add bucket policy"
    type = bool
    default = false
}

variable "role_path" {
    description = "Get role name from ssm path"
    type = string
    default = ""
}