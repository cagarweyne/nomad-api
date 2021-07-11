provider "aws" {
  region = "us-east-2"
}

# terraform backend remote for state data
terraform {
  backend "s3" {
    # s3 bucket details
    bucket = "prod-state-fss-1"
    key = "prod/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    # dynamo db table details for locking
    dynamodb_table = "prod-table-locks"
    encrypt = true
  }
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-prod"
  db_remote_state_bucket = "prod-state-fss-1" 
  db_remote_state_key = "prod/data-stores/pg/terraform.tfstate"

  stripe_secret_key = var.stripe_secret_key
  web_app_url = var.web_app_url
  web_hook_secret = var.web_hook_secret
  service_account = var.service_account
  
  dns_name= "prod-api"
  log_profile_name= "nomad_logs_prod"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 10
}