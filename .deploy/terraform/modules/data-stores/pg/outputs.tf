output "address" {
  value = aws_db_instance.pg_sql_db.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value = aws_db_instance.pg_sql_db.port
  description = "The port the database is listening on"
}

output "db_name" {
  value = aws_db_instance.pg_sql_db.name
  description = "The database name"
}