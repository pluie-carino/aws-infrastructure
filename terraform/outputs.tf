
output "instance_public_ips" {
  description = "Public IPs of both EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "instance_public_dns" {
  description = "Public DNS names of both EC2 instances"
  value       = aws_instance.web[*].public_dns
}

output "availability_zones" {
  description = "Availability Zones of both EC2 instances"
  value       = aws_instance.web[*].availability_zone
}