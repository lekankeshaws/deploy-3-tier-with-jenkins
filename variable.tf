
#########################################################
# VARIABLE FOR PROVIDER BLOCK
#########################################################
variable "region" {
  description = "passing the region"
  type        = string
  default     = "us-east-1"
}

variable "component" {
  description = "passing the component"
  type        = string
  default     = "3-tier-architecture"
}

variable "env" {
  type        = string
  description = "passing the env name"
}

# variable "profile" {
#   type = string
#   description = "passing profile name"
#   default = "iamadmin"
  
# }

#########################################################
# VARIABLE FOR VPC & SUBNET
#########################################################

variable "vpc_cidr" {
  description = "passing the cidr block for the vpc"
  type        = string
}

variable "public_subnet_cidr" {
  description = "passing the cidr for the public subnet"
  type        = list(any)

}

variable "backend_subnet_cidr" {
  description = "passing the cidr for the backend subnet"
  type        = list(any)

}

variable "database_subnet_cidr" {
  description = "passing the cidr for the database subnet"
  type        = list(any)

}

variable "instance_type" {
  description = "passing instance type"
  type        = string
}

#########################################################
# VARIABLE FOR DATABASE
#########################################################

variable "username" {
  type        = string
  description = "db username"
}

variable "port" {
  type        = number
  description = "db port number"
  default     = 3306
}

variable "db_name" {
  type        = string
  description = "db name"
  default     = "webappdb"
}

variable "instance_class" {
  type        = string
  description = "db instance class"

}

#########################################################
# VARIABLE FOR DNS
#########################################################

variable "dns_name" {
  type        = string
  description = "vaue of our dns name"

}

variable "subject_alternative_names" {
  type        = list(any)
  description = "passing the subject alternative domain names"

}

#########################################################
# VARIABLE FOR ALB
#########################################################

variable "health_path" {
  type        = list(string)
  description = "passing the path for alb"

}

variable "rule_value" {
  type        = list(string)
  description = "passing https rule values"
}

variable "alb_priority" {
  type        = list(any)
  description = "passing priority"
  default     = [1, 2]

}
