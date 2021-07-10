provider "aws" {
  region = "us-east-2"
}

module "backend_config" {
  source = "../../../modules/backends/s3"

  bucket_name = "prod-state-fss"
  dynamodb_name = "prod-table-locks" 
  hashKey =  "LockID"
}

# terraform backend remote for s3 stage backend resources - i.e. the bucket and dynamodb table we just created above
terraform {
  backend "s3" {
    # se bucket details
    bucket = "prod-state-fss"
    key = "global/s3/prod/terraform.tfstate" # the key to store the terraform state under in s3
    region = "us-east-2"

    # dynamo db table details for locking
    dynamodb_table = "prod-table-locks"
    encrypt = true
  }
}