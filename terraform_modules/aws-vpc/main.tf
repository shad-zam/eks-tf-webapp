
################################################################################
# DATA
################################################################################
data "aws_availability_zones" "az" {
  state = "available"
}
################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}



################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}




################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
    var.tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
  timeouts {
    create = "5m"
    
  }
}


################################################################################
# Private routes
################################################################################

resource "aws_route_table" "private" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id


  tags = merge(
    {
      "Name" = "${var.name}-private-rt"
    },
    var.tags
  )
}
resource "aws_route" "nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = length(data.aws_availability_zones.az.names) > 0 ? element(data.aws_availability_zones.az.names, count.index) : null
  availability_zone_id    = length(data.aws_availability_zones.az.names) == 0 ? element(data.aws_availability_zones.az.names, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format(
        "${var.name}-${var.public_subnet_suffix}-%s",
        element(data.aws_availability_zones.az.names, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id               = aws_vpc.this[0].id
  cidr_block           = var.private_subnets[count.index]
  availability_zone    = length(data.aws_availability_zones.az.names) > 0 ? element(data.aws_availability_zones.az.names, count.index) : null
  availability_zone_id = length(data.aws_availability_zones.az.names) == 0 ? element(data.aws_availability_zones.az.names, count.index) : null


  tags = merge(
    {
      "Name" = format(
        "${var.name}-${var.private_subnet_suffix}-%s",
        element(data.aws_availability_zones.az.names, count.index),
      )
    },
    var.tags,
  )
}


################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway ? 1 : 0

  vpc = true

  tags = merge(
    {
      "Name" = "${var.name}-natip"
    },
    var.tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  tags = merge(
    {
      "Name" = "${var.name}-natgw"
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.this]
}

################################################################################
# S3 endpoint
################################################################################
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  count = var.create_vpc && var.create_vpce ? 1 : 0
  vpc_id            = aws_vpc.this[0].id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   =  [element(aws_route_table.private[*].id,count.index)]
}



################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id,count.index)
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}
