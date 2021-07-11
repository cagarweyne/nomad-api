output "prod_db_address" {
  value = module.mysql_data_store.address
  description = "Connect to the database at this endpoint"
}

output "prod_db_port" {
  value = module.mysql_data_store.port 
  description = "The port the database is listening on"
}