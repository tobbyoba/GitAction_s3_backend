output "private" {
  value = aws_subnet.private_subnet_cidr.*.id

}

output "public" {
  value = aws_subnet.public_subnet_cidr.*.id
}

output "node_role" {
  value = module.IAM_module.node_role

}

output "demo_role" {
  value = module.IAM_module.demo_role
}

