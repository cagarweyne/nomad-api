provider "aws" {
  region = "us-east-2"
}

# terraform backend remote for state data
terraform {
  backend "s3" {
    # s3 bucket details
    bucket = "stage-state-fss-1"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    # dynamo db table details for locking
    dynamodb_table = "stage-table-locks"
    encrypt = true
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "stage-state-fss-1"
  db_remote_state_key =  "stage/data-stores/mysql/terraform.tfstate"

  stripe_secret_key = var.stripe_secret_key
  web_app_url = var.web_app_url
  web_hook_secret = var.web_hook_secret
  service_account = var.service_account

  instance_type = "t2.micro"
  min_size = 2
  max_size = 10 
}