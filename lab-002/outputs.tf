output "workspace" {
  value = terraform.workspace
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.subnets["public"].id
}

output "private_subnet_id" {
  value = aws_subnet.subnets["private"].id
}

output "bastion_public_ip" {
  value = aws_instance.servers[0].public_ip
}

output "app_private_ip" {
  value = aws_instance.servers[1].private_ip
}