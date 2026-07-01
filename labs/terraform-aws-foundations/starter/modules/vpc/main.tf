locals {
  az_count = length(var.availability_zones)

  # cidrsubnet(prefix, newbits, netnum). For a /16 VPC, newbits = 8 yields /24 subnets.
  newbits = 8

  name_prefix = "${var.project}-${var.environment}"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# ---------------------------------------------------------------------------
# Subnets — one public and one private per AZ.
# ---------------------------------------------------------------------------
# TODO(student): create `aws_subnet.public` with count = local.az_count.
#   - cidr_block must use cidrsubnet(var.vpc_cidr, local.newbits, count.index)
#   - availability_zone = var.availability_zones[count.index]
#   - map_public_ip_on_launch = true
#   - tag Name = "${local.name_prefix}-public-<az>" and Tier = "public"
# resource "aws_subnet" "public" { ... }

# TODO(student): create `aws_subnet.private` with count = local.az_count.
#   - cidr_block must NOT overlap the public range. Offset the netnum by
#     local.az_count: cidrsubnet(var.vpc_cidr, local.newbits, count.index + local.az_count)
#   - availability_zone = var.availability_zones[count.index]
#   - no public IP on launch
#   - tag Name = "${local.name_prefix}-private-<az>" and Tier = "private"
# resource "aws_subnet" "private" { ... }

# ---------------------------------------------------------------------------
# Public routing — default route to the internet gateway, associated to every
# public subnet.
# ---------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# TODO(student): associate every public subnet with aws_route_table.public.
#   Use count = local.az_count and subnet_id = aws_subnet.public[count.index].id
# resource "aws_route_table_association" "public" { ... }

# ---------------------------------------------------------------------------
# Optional NAT gateway — gated on var.enable_nat_gateway to keep the lab at $0.
# ---------------------------------------------------------------------------
# TODO(student): when var.enable_nat_gateway is true, create:
#   1. aws_eip.nat        count = var.enable_nat_gateway ? 1 : 0, domain = "vpc"
#   2. aws_nat_gateway.this  count = ...?1:0, allocation_id = aws_eip.nat[0].id,
#                            subnet_id = aws_subnet.public[0].id
#   3. aws_route.private_nat count = ...?1:0, route_table_id = aws_route_table.private.id,
#                            destination_cidr_block = "0.0.0.0/0",
#                            nat_gateway_id = aws_nat_gateway.this[0].id
#   Add depends_on = [aws_internet_gateway.this] to the EIP and NAT gateway.
# resource "aws_eip" "nat" { ... }
# resource "aws_nat_gateway" "this" { ... }

# Private route table always exists; the default route is added only when NAT is on.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

# TODO(student): add the aws_route.private_nat resource here (see NAT block above).

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------
# Lock down the default security group: deny all ingress and egress (CIS best
# practice) so nothing accidentally uses the permissive default SG.
# ---------------------------------------------------------------------------
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  # No ingress or egress blocks => all rules revoked.

  tags = {
    Name = "${local.name_prefix}-default-sg-locked"
  }
}
