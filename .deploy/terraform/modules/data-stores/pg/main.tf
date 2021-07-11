locals {
  pg_port = 5432
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_security_group" "pg_sg" {
  name = var.db_security_group_name
  description = "RDS (terraform-managed) postgres db"

  # Only PG in
  ingress {
    from_port   = local.pg_port
    to_port     = local.pg_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  # Allow all outbound traffic.
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }
}

resource "aws_db_instance" "pg_sql_db" {
  identifier_prefix      = var.instance_prefix
  engine                 = "postgres"
  allocated_storage      = var.storage
  instance_class         = var.instance_class # "db.t2.micro" 
  name                   = var.db_name
  username               = var.username
  skip_final_snapshot    = true # needed to delete the db when using teraform destroy 
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.pg_sg.id]
  password               = var.db_password
}