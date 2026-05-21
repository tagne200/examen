# ============================================
# DIGITRANS-CM - Environnement STAGING
# ============================================

# Informations générales
project_name = "digitrans-crm"
environment  = "staging"
aws_region   = "af-south-1"

# VPC et Réseau
vpc_cidr        = "10.1.0.0/16"
public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets = ["10.1.10.0/24", "10.1.11.0/24"]

# RDS PostgreSQL - Configuration intermédiaire
db_instance_class      = "db.t3.small"
db_allocated_storage   = 50
db_name                = "crm_staging_db"
db_username            = "admin"
db_multi_az            = false  # Single-AZ pour staging
db_backup_retention    = 7      # 7 jours de backup

# ElastiCache Redis - Configuration intermédiaire
elasticache_node_type    = "cache.t3.small"
elasticache_num_nodes    = 1
elasticache_engine_version = "7.0"

# Lambda - Configuration staging
lambda_runtime              = "python3.11"
lambda_memory_size          = 512
lambda_timeout              = 120
lambda_reserved_concurrency = 50  # Réservation modérée

# S3 et CloudFront
s3_bucket_name         = "digitrans-crm-frontend-staging"
cloudfront_price_class = "PriceClass_100"

# Monitoring - Activé en staging
enable_detailed_monitoring = true
log_retention_days         = 30

# Alertes
alert_email = "staging-alerts@camtech-solutions.cm"

# Tags additionnels
additional_tags = {
  CostCenter = "Staging"
  Team       = "QA"
  Backup     = "true"
}

# EKS Configuration
eks_instance_type  = "t3.medium"
eks_desired_nodes  = 2
eks_min_nodes      = 1
eks_max_nodes      = 4
