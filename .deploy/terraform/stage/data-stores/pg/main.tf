provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    # se bucket details
    bucket = "stage-state-fss-1"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    # dynamo db table details for locking
    dynamodb_table = "stage-table-locks"
    encrypt = true
  }
}

module "pgsql_data_store" {
  source = "../../../modules/data-stores/pg"

  instance_prefix = "stage-pgsql"
  storage = 50
  instance_class = "db.t3.micro"
  db_name = "stage_database"
  username = "nomad"
  db_password = var.db_password
  db_security_group_name = "pg-rds-sg"  
}