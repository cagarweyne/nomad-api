output "address" {
  value = module.pgsql_data_store.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value = module.pgsql_data_store.port 
  description = "The port the database is listening on"
}

output "db_name" {
  value = module.pgsql_data_store.db_name 
  description = "The database name"
}