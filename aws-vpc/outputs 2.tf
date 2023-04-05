output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this[0].id, "")
}

output "public_subnet_ids" {
  description = "ID of the public subnets"
  value = try(aws_subnet.public[*].id, [])
}

output "db_subnet_ids" {
    description = "DB subnet IDs"
    value = try(aws_subnet.database[*].id,[])
}

output "ecs_subnet_ids" {
  description = "ID of the public subnets"
  value = try(aws_subnet.ecs[*].id, [])
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.this[0].arn, "")
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.this[0].cidr_block, "")
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = try(aws_vpc.this[0].default_security_group_id, "")
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = try(aws_vpc.this[0].default_network_acl_id, "")
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = try(aws_vpc.this[0].default_route_table_id, "")
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = try(aws_vpc.this[0].instance_tenancy, "")
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = try(aws_vpc.this[0].enable_dns_support, "")
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = try(aws_vpc.this[0].enable_dns_hostnames, "")
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = try(aws_vpc.this[0].main_route_table_id, "")
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = try(aws_vpc.this[0].ipv6_association_id, "")
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = try(aws_vpc.this[0].ipv6_cidr_block, "")
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = compact(aws_vpc_ipv4_cidr_block_association.this[*].cidr_block)
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = try(aws_vpc.this[0].owner_id, "")
}

output "ecs_subnets" {
  description = "List of IDs of ecs subnets"
  value       = aws_subnet.ecs[*].id
}

output "ecs_subnet_arns" {
  description = "List of ARNs of ecs subnets"
  value       = aws_subnet.ecs[*].arn
}

output "mq_subnets" {
  description = "List of IDs of mq subnets"
  value       = aws_subnet.mq[*].id
}

output "mq_subnet_arns" {
  description = "List of ARNs of mq subnets"
  value       = aws_subnet.mq[*].arn
}

output "ecs_subnets_cidr_blocks" {
  description = "List of cidr_blocks of ecs subnets"
  value       = compact(aws_subnet.ecs[*].cidr_block)
}

output "ecs_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of ecs subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.ecs[*].ipv6_cidr_block)
}

output "mq_subnets_cidr_blocks" {
  description = "List of cidr_blocks of mq subnets"
  value       = compact(aws_subnet.mq[*].cidr_block)
}

output "mq_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of mq subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.mq[*].ipv6_cidr_block)
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = compact(aws_subnet.private[*].cidr_block)
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.private[*].ipv6_cidr_block)
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = compact(aws_subnet.public[*].cidr_block)
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.public[*].ipv6_cidr_block)
}

output "outpost_subnets" {
  description = "List of IDs of outpost subnets"
  value       = aws_subnet.outpost[*].id
}

output "outpost_subnet_arns" {
  description = "List of ARNs of outpost subnets"
  value       = aws_subnet.outpost[*].arn
}

output "outpost_subnets_cidr_blocks" {
  description = "List of cidr_blocks of outpost subnets"
  value       = compact(aws_subnet.outpost[*].cidr_block)
}

output "outpost_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of outpost subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.outpost[*].ipv6_cidr_block)
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = compact(aws_subnet.database[*].cidr_block)
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of database subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.database[*].ipv6_cidr_block)
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = try(aws_db_subnet_group.database[0].id, "")
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = try(aws_db_subnet_group.database[0].name, "")
}

output "eks_subnets" {
  description = "List of IDs of eks subnets"
  value       = aws_subnet.eks[*].id
}

output "eks_subnet_arns" {
  description = "List of ARNs of eks subnets"
  value       = aws_subnet.eks[*].arn
}

output "eks_subnets_cidr_blocks" {
  description = "List of cidr_blocks of eks subnets"
  value       = compact(aws_subnet.eks[*].cidr_block)
}

output "eks_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of eks subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.eks[*].ipv6_cidr_block)
}


output "cache_subnets" {
  description = "List of IDs of cache subnets"
  value       = aws_subnet.cache[*].id
}

output "cache_subnet_arns" {
  description = "List of ARNs of cache subnets"
  value       = aws_subnet.cache[*].arn
}

output "cache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of cache subnets"
  value       = compact(aws_subnet.cache[*].cidr_block)
}

output "cache_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of cache subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.cache[*].ipv6_cidr_block)
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = aws_subnet.intra[*].id
}

output "intra_subnet_arns" {
  description = "List of ARNs of intra subnets"
  value       = aws_subnet.intra[*].arn
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = compact(aws_subnet.intra[*].cidr_block)
}

output "intra_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of intra subnets in an IPv6 enabled VPC"
  value       = compact(aws_subnet.intra[*].ipv6_cidr_block)
}

output "ecs_route_table_ids" {
  description = "List of IDs of ecs route tables"
  value       = length(aws_route_table.ecs[*].id) > 0 ? aws_route_table.ecs[*].id :  []
}

output "mq_route_table_ids" {
  description = "List of IDs of mq route tables"
  value       = length(aws_route_table.mq[*].id) > 0 ? aws_route_table.mq[*].id :  []
}

output "all_private_route_table_ids" {
  value = concat(
    try(aws_route_table.ecs[*].id,[]),
    try(aws_route_table.eks[*].id,[]),
    try(aws_route_table.database[*].id,[]),
    try(aws_route_table.cache[*].id,[]),
    try(aws_route_table.private[*].id,[]),
  )
  description = "List of IDs of all private route tables"
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = length(aws_route_table.database[*].id)>0 ? aws_route_table.database[*].id : []
}

output "eks_route_table_ids" {
  description = "List of IDs of eks route tables"
  value       = length(aws_route_table.eks[*].id) > 0 ? aws_route_table.eks[*].id : []
}

output "cache_route_table_ids" {
  description = "List of IDs of cache route tables"
  value       = try(coalescelist(aws_route_table.cache[*].id, aws_route_table.private[*].id), [])
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = aws_route_table.intra[*].id
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route"
  value       = try(aws_route.public_internet_gateway[0].id, "")
}

output "public_internet_gateway_ipv6_route_id" {
  description = "ID of the IPv6 internet gateway route"
  value       = try(aws_route.public_internet_gateway_ipv6[0].id, "")
}

output "database_internet_gateway_route_id" {
  description = "ID of the database internet gateway route"
  value       = try(aws_route.database_internet_gateway[0].id, "")
}

output "database_nat_gateway_route_ids" {
  description = "List of IDs of the database nat gateway route"
  value       = aws_route.database_nat_gateway[*].id
}

output "database_ipv6_egress_route_id" {
  description = "ID of the database IPv6 egress route"
  value       = try(aws_route.database_ipv6_egress[0].id, "")
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route"
  value       = aws_route.private_nat_gateway[*].id
}

output "private_ipv6_egress_route_ids" {
  description = "List of IDs of the ipv6 egress route"
  value       = aws_route.private_ipv6_egress[*].id
}

output "ecs_route_table_association_ids" {
  description = "List of IDs of the ecs route table association"
  value       = aws_route_table_association.ecs[*].id
}

output "mq_route_table_association_ids" {
  description = "List of IDs of the mq route table association"
  value       = aws_route_table_association.mq[*].id
}


output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = aws_route_table_association.private[*].id
}

output "database_route_table_association_ids" {
  description = "List of IDs of the database route table association"
  value       = aws_route_table_association.database[*].id
}

output "eks_route_table_association_ids" {
  description = "List of IDs of the eks route table association"
  value       = aws_route_table_association.eks[*].id
}

output "eks_public_route_table_association_ids" {
  description = "List of IDs of the public redshidt route table association"
  value       = aws_route_table_association.eks_public[*].id
}

output "cache_route_table_association_ids" {
  description = "List of IDs of the cache route table association"
  value       = aws_route_table_association.cache[*].id
}

output "intra_route_table_association_ids" {
  description = "List of IDs of the intra route table association"
  value       = aws_route_table_association.intra[*].id
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = aws_route_table_association.public[*].id
}

output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value       = try(aws_vpc_dhcp_options.this[0].id, "")
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = var.reuse_nat_ips ? var.external_nat_ips : aws_eip.nat[*].public_ip
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, "")
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].arn, "")
}

output "egress_only_internet_gateway_id" {
  description = "The ID of the egress only Internet Gateway"
  value       = try(aws_egress_only_internet_gateway.this[0].id, "")
}

output "cgw_ids" {
  description = "List of IDs of Customer Gateway"
  value       = [for k, v in aws_customer_gateway.this : v.id]
}

output "cgw_arns" {
  description = "List of ARNs of Customer Gateway"
  value       = [for k, v in aws_customer_gateway.this : v.arn]
}

output "this_customer_gateway" {
  description = "Map of Customer Gateway attributes"
  value       = aws_customer_gateway.this
}

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = try(aws_vpn_gateway.this[0].id, aws_vpn_gateway_attachment.this[0].vpn_gateway_id, "")
}

output "vgw_arn" {
  description = "The ARN of the VPN Gateway"
  value       = try(aws_vpn_gateway.this[0].arn, "")
}

output "default_vpc_id" {
  description = "The ID of the Default VPC"
  value       = try(aws_default_vpc.this[0].id, "")
}

output "default_vpc_arn" {
  description = "The ARN of the Default VPC"
  value       = try(aws_default_vpc.this[0].arn, "")
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the Default VPC"
  value       = try(aws_default_vpc.this[0].cidr_block, "")
}

output "default_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on Default VPC creation"
  value       = try(aws_default_vpc.this[0].default_security_group_id, "")
}

output "default_vpc_default_network_acl_id" {
  description = "The ID of the default network ACL of the Default VPC"
  value       = try(aws_default_vpc.this[0].default_network_acl_id, "")
}

output "default_vpc_default_route_table_id" {
  description = "The ID of the default route table of the Default VPC"
  value       = try(aws_default_vpc.this[0].default_route_table_id, "")
}

output "default_vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within Default VPC"
  value       = try(aws_default_vpc.this[0].instance_tenancy, "")
}

output "default_vpc_enable_dns_support" {
  description = "Whether or not the Default VPC has DNS support"
  value       = try(aws_default_vpc.this[0].enable_dns_support, "")
}

output "default_vpc_enable_dns_hostnames" {
  description = "Whether or not the Default VPC has DNS hostname support"
  value       = try(aws_default_vpc.this[0].enable_dns_hostnames, "")
}

output "default_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with the Default VPC"
  value       = try(aws_default_vpc.this[0].main_route_table_id, "")
}


output "ecs_network_acl_id" {
  description = "ID of the ecs network ACL"
  value       = try(aws_network_acl.ecs[0].id, "")
}

output "ecs_network_acl_arn" {
  description = "ARN of the ecs network ACL"
  value       = try(aws_network_acl.ecs[0].arn, "")
}

output "mq_network_acl_id" {
  description = "ID of the mq network ACL"
  value       = try(aws_network_acl.mq[0].id, "")
}

output "mq_network_acl_arn" {
  description = "ARN of the mq network ACL"
  value       = try(aws_network_acl.mq[0].arn, "")
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = try(aws_network_acl.public[0].id, "")
}

output "public_network_acl_arn" {
  description = "ARN of the public network ACL"
  value       = try(aws_network_acl.public[0].arn, "")
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = try(aws_network_acl.private[0].id, "")
}

output "private_network_acl_arn" {
  description = "ARN of the private network ACL"
  value       = try(aws_network_acl.private[0].arn, "")
}

output "outpost_network_acl_id" {
  description = "ID of the outpost network ACL"
  value       = try(aws_network_acl.outpost[0].id, "")
}

output "outpost_network_acl_arn" {
  description = "ARN of the outpost network ACL"
  value       = try(aws_network_acl.outpost[0].arn, "")
}

output "intra_network_acl_id" {
  description = "ID of the intra network ACL"
  value       = try(aws_network_acl.intra[0].id, "")
}

output "intra_network_acl_arn" {
  description = "ARN of the intra network ACL"
  value       = try(aws_network_acl.intra[0].arn, "")
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = try(aws_network_acl.database[0].id, "")
}

output "database_network_acl_arn" {
  description = "ARN of the database network ACL"
  value       = try(aws_network_acl.database[0].arn, "")
}

output "eks_network_acl_id" {
  description = "ID of the eks network ACL"
  value       = try(aws_network_acl.eks[0].id, "")
}

output "eks_network_acl_arn" {
  description = "ARN of the eks network ACL"
  value       = try(aws_network_acl.eks[0].arn, "")
}

output "cache_network_acl_id" {
  description = "ID of the cache network ACL"
  value       = try(aws_network_acl.cache[0].id, "")
}

output "cache_network_acl_arn" {
  description = "ARN of the cache network ACL"
  value       = try(aws_network_acl.cache[0].arn, "")
}

# VPC flow log
output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = try(aws_flow_log.this[0].id, "")
}

output "vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = local.flow_log_destination_arn
}

output "vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = var.flow_log_destination_type
}

output "vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value       = local.flow_log_iam_role_arn
}

# Static values (arguments)
output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = var.name
}
