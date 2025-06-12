output "public_subnet_1" {
  value = aws_subnet.public_subnet[0]
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet[1]
}

output "private_subnet_1" {
  value = aws_subnet.private_subnet[0]
}

output "private_subnet_2" {
  value = aws_subnet.private_subnet[1]
}
