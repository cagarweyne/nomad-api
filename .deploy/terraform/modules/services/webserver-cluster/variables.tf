variable "stripe_secret_key" {
  description = "The Stripe secret key"
  type = string
}

variable "web_app_url" {
  description = "Web app url to redirect user after payment"
  type = string
}

variable "web_hook_secret" {
  description = "The Stripe webhook secret"
  type = string
}

variable "service_account" {
  description = "The service account file name used for auth"
  type = string
  default = "./service-account.json"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state key in S3 bucket"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g t2.Micro)"
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
  type = number
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "cidr_public_subnet_1" {
  description = "CIDR block for the public subnet 1"
  default     = "10.0.0.0/24"
}

variable "cidr_public_subnet_2" {
  description = "CIDR block for the public subnet 2"
  default     = "10.0.1.0/24"
}

variable "cidr_public_subnet_3" {
  description = "CIDR block for the public subnet 3"
  default     = "10.0.3.0/24"
}

// private subnet cidr blocks
variable "cidr_private_subnet_1" {
  description = "CIDR block for the private subnet 1"
  default     = "10.0.4.0/24"
}

variable "cidr_private_subnet_2" {
  description = "CIDR block for the private subnet 2"
  default     = "10.0.5.0/24"
}

variable "cidr_private_subnet_3" {
  description = "CIDR block for the private subnet 3"
  default     = "10.0.6.0/24"
}

variable "dns_hosted_zone" {
  description = "The name of our dns hosted zone"
  default = "cagaros.com"
}


variable "dns_name" {
  description = "subdomain name"
}

variable "log_profile_name" {
  description = "The logs profile for aws instance"
}



