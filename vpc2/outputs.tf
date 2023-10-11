output "private" {
  value = aws_subnet.private_subnet_cidr.*.id

}

output "public" {
  value = aws_subnet.public_subnet_cidr.*.id
}



