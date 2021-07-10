provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    # se bucket details
    bucket = "prod-state-fss"
    key = "prod/data-stores/mysql/terraform.tfstate" # the key to store the terraform state under in s3
    region = "us-east-2"

    # dynamo db table details for locking
    dynamodb_table = "prod-table-locks"
    encrypt = true
  }
}

module "pgsql_data_store" {
  source = "../../../modules/data-stores/pg"

  instance_prefix = "prod-pgsql"
  storage = 10
  instance_class = "db.t2.micro"
  db_name = "prod_database"
  username = "nomad"
  db_password = var.db_password 
}