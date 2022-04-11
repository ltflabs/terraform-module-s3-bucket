output "this_bucket_role_access_id" {
  value = aws_s3_bucket.this_bucket.id
}

output "this_bucket_role_access_arn" {
  value = aws_s3_bucket.this_bucket.arn
}

output "this_bucket_role_access_name" {
  value = aws_s3_bucket.this_bucket.name
}

output "project_sns_topic_arn" {
  value = aws_sns_topic.project_sns_topic.arn
}

output "snowflake_storage_integration.integration_name" {
  value = snowflake_storage_integration.integration.name
}

output "snowflake_storage_integration.integration_user_arn" {
  value = snowflake_storage_integration.integration.storage_aws_iam_user_arn
}

output "snowflake_storage_integration.integration_external_id" {
  value = snowflake_storage_integration.integration.storage_aws_external_id
}