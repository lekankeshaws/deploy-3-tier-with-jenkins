
# TAGGING VARIABLE
env = "sandbox"

# VPC VARIABLE 
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = ["10.0.0.0/24", "10.0.2.0/24"]
backend_subnet_cidr  = ["10.0.1.0/24", "10.0.3.0/24"]
database_subnet_cidr = ["10.0.51.0/24", "10.0.53.0/24"]

# EC2 VARIABLE
instance_type  = "t2.micro"
username       = "admin"
instance_class = "db.t2.micro"

# DNS VARIABLE
dns_name                  = "keshinro.link"
subject_alternative_names = ["*.keshinro.link"]

# ALB VARIABLE
health_path = ["/app1/index.html", "/app2/index.html"]
rule_value  = ["/app1*", "/app2*"]