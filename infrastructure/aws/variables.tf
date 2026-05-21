# ============================================
# DIGITRANS-CM - Variables Terraform AWS
# ============================================

# ============================================
# Variables Générales
# ============================================

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "digitrans-crm"
}

variable "environment" {
  description = "Environnement (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "L'environnement doit être dev, staging ou production."
  }
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "af-south-1"
}

# ============================================
# Variables VPC et Réseau
# ============================================

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Liste des CIDR blocks pour les subnets publics"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Liste des CIDR blocks pour les subnets privés"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ============================================
# Variables RDS PostgreSQL
# ============================================

variable "db_instance_class" {
  description = "Classe d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Stockage alloué en GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "crm_db"
}

variable "db_username" {
  description = "Nom d'utilisateur de la base de données"
  type        = string
  default     = "admin"
}

variable "db_multi_az" {
  description = "Activer Multi-AZ pour RDS"
  type        = bool
  default     = false
}

variable "db_backup_retention" {
  description = "Nombre de jours de rétention des backups"
  type        = number
  default     = 7
}

# ============================================
# Variables ElastiCache Redis
# ============================================

variable "elasticache_node_type" {
  description = "Type de nœud ElastiCache"
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_num_nodes" {
  description = "Nombre de nœuds ElastiCache"
  type        = number
  default     = 1
}

variable "elasticache_engine_version" {
  description = "Version du moteur Redis"
  type        = string
  default     = "7.0"
}

# ============================================
# Variables Lambda
# ============================================

variable "lambda_runtime" {
  description = "Runtime Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_memory_size" {
  description = "Mémoire Lambda en MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout Lambda en secondes"
  type        = number
  default     = 30
}

variable "lambda_reserved_concurrency" {
  description = "Concurrence réservée Lambda"
  type        = number
  default     = 0
}

# ============================================
# Variables S3 et CloudFront
# ============================================

variable "s3_bucket_name" {
  description = "Nom du bucket S3 pour le frontend"
  type        = string
  default     = ""
}

variable "cloudfront_price_class" {
  description = "Classe de prix CloudFront"
  type        = string
  default     = "PriceClass_100"
}

# ============================================
# Variables Monitoring
# ============================================

variable "enable_detailed_monitoring" {
  description = "Activer le monitoring détaillé"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Nombre de jours de rétention des logs CloudWatch"
  type        = number
  default     = 7
}

# ============================================
# Variables Alertes
# ============================================

variable "alert_email" {
  description = "Email pour les alertes"
  type        = string
  default     = "devops@camtech-solutions.cm"
}

# ============================================
# Variables Azure (pour intégration)
# ============================================

variable "azure_tenant_id" {
  description = "Azure AD Tenant ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure AD Client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure AD Client Secret"
  type        = string
  default     = ""
  sensitive   = true
}

# ============================================
# Variables Tags
# ============================================

variable "additional_tags" {
  description = "Tags additionnels à appliquer aux ressources"
  type        = map(string)
  default     = {}
}
