output "prod_alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer for prod env"
}

output "lb_https_url" {
  value = module.webserver_cluster.lb_url
  description = "The domain name of the load balancer for prod env"
}

output "ami_id" {
  value = module.webserver_cluster.ami_id
  description = "The AMI id pulled from aws"
}