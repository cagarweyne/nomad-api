# # output variables stage environment
output "prod_s3_bucket_arn" {
  value = module.backend_config.s3_bucket_arn
  description = "The ARN of the remote s3 bucket"
}

output "prod_dynamodb_table_name" {
  value = module.backend_config.dynamodb_table_name
  description = "The name of the dynamodb table for locking remote state"
}