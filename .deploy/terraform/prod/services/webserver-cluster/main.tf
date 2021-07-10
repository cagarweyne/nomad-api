provider "aws" {
  region = "us-east-2"
}

# terraform backend remote for state data
terraform {
  backend "s3" {
    # s3 bucket details
    bucket = "prod-state-fss"
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
  db_remote_state_bucket = "prod-state-fss" 
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 10
}

# scale up the number of instances during the busy working day hours
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10 
  desired_capacity = 10 
  recurrence = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

# scale down the number of instances at the end of working day
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10 
  desired_capacity = 2 
  recurrence = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}