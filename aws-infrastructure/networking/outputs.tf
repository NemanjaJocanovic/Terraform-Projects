# ... networking/outputs.tf ...

output "vpc_id" {
  value = aws_vpc.n_vpc.id
}

output "rds_sng_name" {
  value = aws_db_subnet_group.rds_subnetgroup.*.name
}

output "rds_sg" {
  value = [aws_security_group.n_sg["rds"].id]
}

output "public_sg" {
  value = aws_security_group.n_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}