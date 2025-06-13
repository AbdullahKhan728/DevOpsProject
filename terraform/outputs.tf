output "vpc_id" {
  value = module.vpc.vpc_id
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}
output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}


# 