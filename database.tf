

#########################################################
# CREATING RANDOM PASSWORD 
#########################################################

resource "random_password" "password" {
  length  = 16
  special = true
}

#########################################################
# CREATING SECRET MANAGER
#########################################################

resource "aws_secretsmanager_secret" "this" {
  name_prefix = "registration_app_db"
  description = "secret to manage superuser ${var.username} password"
}

resource "aws_secretsmanager_secret_version" "registration_app" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.db_secret)
}

locals {
  db_secret = {
    endpoint = aws_db_instance.registration_app_db.address
    db_name  = var.db_name
    username = var.username
    password = random_password.password.result
    port     = var.port
  }
}
#########################################################
# CREATING DATABASE SUBNET
#########################################################

resource "aws_db_subnet_group" "this" {
  name       = "database subnet"
  subnet_ids = module.vpc.database_subnet_id

  tags = {
    Name = "My DB subnet group"
  }
}

#########################################################
# CREATING MYSQL DATABASE
#########################################################

resource "aws_db_instance" "registration_app_db" {
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  instance_class         = var.instance_class
  username               = var.username
  password               = random_password.password.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  port                   = var.port
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.security["registration_sg"].id]
}