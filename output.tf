

output "public_subnet_ids" {
  value = module.vpc.public_subnet_id
}

output "ngw_id" {
  value = module.vpc.nat_gw_id
}

output "ec2_public_ip" {
  value = aws_instance.app1.arn
}