locals {
  az_count = length(var.availability_zones)

  # Carve /24-style subnets out of the VPC CIDR with cidrsubnet(prefix, newbits, netnum).
  # For a /16 VPC, newbits = 8 yields /24 subnets. Public subnets take netnums 0..az_count-1;
  # private subnets take netnums az_count..2*az_count-1 so the two ranges never overlap.
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
# VPC flow logs — capture all network traffic metadata for security/audit and
# ship it to CloudWatch Logs. Best practice (CIS, checkov CKV2_AWS_11). The log
# group is encrypted with a customer-managed KMS key and has a finite retention.
# The log group itself is free; you only pay for log ingestion/storage once real
# traffic flows, so this stays $0 to validate (no apply is ever run).
# ---------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# KMS key used to encrypt the flow-log CloudWatch log group at rest.
resource "aws_kms_key" "flow_logs" {
  description             = "${local.name_prefix} VPC flow logs encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Allow CloudWatch Logs in this region to use the key, plus the account root
  # for administration. Without the logs.<region> grant, the encrypted log group
  # cannot be created.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAccountAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogs"
        Effect    = "Allow"
        Principal = { Service = "logs.${data.aws_region.current.name}.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = "*"
      },
    ]
  })

  tags = {
    Name = "${local.name_prefix}-flow-logs-kms"
  }
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc-flow-logs/${local.name_prefix}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.flow_logs.arn

  tags = {
    Name = "${local.name_prefix}-flow-logs"
  }
}

# IAM role the VPC flow-log service assumes to write into the log group.
data "aws_iam_policy_document" "flow_logs_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = "${local.name_prefix}-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume.json

  tags = {
    Name = "${local.name_prefix}-flow-logs"
  }
}

# Scoped to just this VPC's log group + its log streams (least privilege).
data "aws_iam_policy_document" "flow_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      aws_cloudwatch_log_group.flow_logs.arn,
      "${aws_cloudwatch_log_group.flow_logs.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${local.name_prefix}-flow-logs"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "this" {
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  tags = {
    Name = "${local.name_prefix}-flow-logs"
  }
}

# ---------------------------------------------------------------------------
# Subnets — one public and one private per AZ.
# ---------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = local.az_count

  # checkov:skip=CKV_AWS_130: This is intentionally a PUBLIC subnet — auto-
  # assigning a public IP is its defining behaviour and a core teaching goal of
  # this lab (public vs private subnet). Private subnets (aws_subnet.private)
  # correctly leave map_public_ip_on_launch off. Hosts that should not be
  # internet-reachable belong in the private subnets, not here.
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.newbits, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${var.availability_zones[count.index]}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.newbits, count.index + local.az_count)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${local.name_prefix}-private-${var.availability_zones[count.index]}"
    Tier = "private"
  }
}

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

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Optional NAT gateway — a single NAT in the first public subnet gives private
# subnets outbound egress. Gated on enable_nat_gateway to keep the lab at $0.
# ---------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${local.name_prefix}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

# Private route table is created whether or not NAT is enabled, so private
# subnets always have an explicit, locked-down route table (no default route
# when NAT is off). The default route is added only when NAT exists.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------
# Lock down the default security group: deny all ingress and egress by managing
# it with no rules. This is an AWS best practice (CIS) so nothing accidentally
# uses the permissive default SG.
# ---------------------------------------------------------------------------
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  # No ingress or egress blocks => all rules revoked.

  tags = {
    Name = "${local.name_prefix}-default-sg-locked"
  }
}
