# ============================================
# DIGITRANS-CM - Environnement DÉVELOPPEMENT
# ============================================

# Informations générales
project_name = "digitrans-crm"
environment  = "dev"
aws_region   = "af-south-1"

# VPC et Réseau
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

# RDS PostgreSQL - Configuration minimale pour dev
db_instance_class      = "db.t3.micro"
db_allocated_storage   = 20
db_name                = "crm_dev_db"
db_username            = "admin"
db_multi_az            = false  # Pas de Multi-AZ en dev
db_backup_retention    = 1      # 1 jour de backup

# ElastiCache Redis - Configuration minimale
elasticache_node_type    = "cache.t3.micro"
elasticache_num_nodes    = 1
elasticache_engine_version = "7.0"

# Lambda - Configuration dev
lambda_runtime              = "python3.11"
lambda_memory_size          = 256
lambda_timeout              = 60
lambda_reserved_concurrency = 0  # Pas de réservation en dev

# S3 et CloudFront
s3_bucket_name         = "digitrans-crm-frontend-dev"
cloudfront_price_class = "PriceClass_100"

# Monitoring - Minimal en dev
enable_detailed_monitoring = false
log_retention_days         = 7

# Alertes
alert_email = "dev-team@camtech-solutions.cm"

# Tags additionnels
additional_tags = {
  CostCenter = "Development"
  Team       = "DevOps"
  Backup     = "false"
}

# EKS Configuration
eks_instance_type  = "t3.small"
eks_desired_nodes  = 1
eks_min_nodes      = 1
eks_max_nodes      = 2
