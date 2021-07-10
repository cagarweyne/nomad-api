provider "aws" {
  region = "us-east-2"
}

module "backend_config" {
  source = "../../../modules/backends/s3"

  bucket_name = "stage-state-fss-1"
  dynamodb_name = "stage-table-locks" 
  hashKey =  "LockID"
}

# terraform backend remote for s3 stage backend resources - i.e. the bucket and dynamodb table we just created above
terraform {
  backend "s3" {
    # set bucket details
    bucket = "stage-state-fss-1"
    key = "global/s3/stage/terraform.tfstate" 
    region = "us-east-2"

    # dynamo db table details for locking
    dynamodb_table = "stage-table-locks"
    encrypt = true
  }
}





