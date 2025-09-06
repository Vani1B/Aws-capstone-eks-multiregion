output "vpc_id"                 { value = aws_vpc.vpc.id }
output "vpc_cidr"               { value = var.cidr_block }
output "public_subnet_ids"      { value = [for s in aws_subnet.public  : s.id] }
output "private_subnet_ids"     { value = [for s in aws_subnet.private : s.id] }
output "vpce_security_group"    { value = aws_security_group.vpce.id }
output "private_route_table_ids"{ value = [for rt in aws_route_table.private : rt.id] }
