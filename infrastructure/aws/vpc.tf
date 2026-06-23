# ============================================
# DIGITRANS-CM - Configuration VPC
# ============================================

# ============================================
# VPC Principal
# ============================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-vpc"
    }
  )
}

# ============================================
# Internet Gateway
# ============================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-igw"
    }
  )
}

# ============================================
# Subnets Publics
# ============================================

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-public-${count.index + 1}"
      Type = "Public"
      Tier = "Public"
    }
  )
}

# ============================================
# Subnets Privés
# ============================================

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-private-${count.index + 1}"
      Type = "Private"
      Tier = "Database"
    }
  )
}

# ============================================
# Elastic IP pour NAT Gateway
# ============================================

resource "aws_eip" "nat" {
  count  = var.environment == "production" ? length(local.azs) : 1
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================
# NAT Gateway
# ============================================

resource "aws_nat_gateway" "main" {
  count         = var.environment == "production" ? length(local.azs) : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================
# Route Table Publique
# ============================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-public-rt"
      Type = "Public"
    }
  )
}

# ============================================
# Association Route Table Publique
# ============================================

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================
# Route Tables Privées
# ============================================

resource "aws_route_table" "private" {
  count  = var.environment == "production" ? length(local.azs) : 1
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-private-rt-${count.index + 1}"
      Type = "Private"
    }
  )
}

# ============================================
# Association Route Tables Privées
# ============================================

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.environment == "production" ? count.index : 0].id
}

# ============================================
# VPC Endpoints (pour économiser les coûts)
# ============================================

# S3 Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-s3-endpoint"
    }
  )
}

# Association S3 Endpoint avec route tables
resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  count           = length(aws_route_table.private)
  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

# ============================================
# Network ACLs (optionnel - sécurité supplémentaire)
# ============================================

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  # Règle entrante : Autoriser tout le trafic HTTP/HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Règle entrante : Autoriser les réponses
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Règle sortante : Autoriser tout
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-public-nacl"
    }
  )
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Règle entrante : Autoriser tout le trafic interne au VPC
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Règle entrante : Autoriser le trafic de RETOUR depuis Internet (via NAT)
  # Indispensable pour que les nodes EKS rejoignent le cluster (ECR, API EKS).
  # Les NACL étant stateless, les réponses arrivent sur des ports éphémères.
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Règle sortante : Autoriser tout
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-private-nacl"
    }
  )
}
