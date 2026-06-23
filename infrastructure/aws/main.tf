# ============================================
# DIGITRANS-CM - Infrastructure AWS
# Terraform Configuration
# ============================================

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  
  # Backend S3 pour stocker l'état Terraform
  # bucket et key sont passés via -backend-config dans le pipeline CI/CD
  backend "s3" {
    region         = "af-south-1"
    encrypt        = true
    dynamodb_table = "digitrans-terraform-locks"
  }
}

# ============================================
# Provider AWS Configuration
# ============================================

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "CAMTECH-SOLUTIONS"
      CostCenter  = "DIGITRANS-CM"
    }
  }
}

# ============================================
# Data Sources
# ============================================

# Récupérer les zones de disponibilité
data "aws_availability_zones" "available" {
  state = "available"
}

# Récupérer l'identité du compte AWS
data "aws_caller_identity" "current" {}

# ============================================
# Locals
# ============================================

locals {
  # Nom complet du projet
  full_name = "${var.project_name}-${var.environment}"
  
  # Tags communs
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Zones de disponibilité (2 premières)
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

# ============================================
# Outputs
# ============================================

output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs des subnets privés"
  value       = aws_subnet.private[*].id
}

output "rds_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "Nom de la base de données"
  value       = aws_db_instance.main.db_name
}

output "db_password_secret_arn" {
  description = "ARN du secret contenant le mot de passe DB"
  value       = aws_secretsmanager_secret.db_password.arn
  sensitive   = true
}
