variable "bucket_name" {
  description = "The name of the s3 bucket"
  type = string
}

variable "dynamodb_name" {
  description = "The name of the dynamo db for locking"
  type = string
}

variable "hashKey" {
  description = "The hash key for the dynamodb"
  type = string
}