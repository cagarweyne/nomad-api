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
  stripe_secret_key = var.stripe_secret_key
  web_app_url = var.web_app_url
  web_hook_secret = var.web_hook_secret

  dns_name= "dev-api"
  log_profile_name= "nomad_logs_profile"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 3 
}