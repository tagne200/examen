# ============================================
# DIGITRANS-CM - Environnement PRODUCTION
# ============================================

# Informations générales
project_name = "digitrans-crm"
environment  = "production"
aws_region   = "af-south-1"

# VPC et Réseau
vpc_cidr        = "10.2.0.0/16"
public_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnets = ["10.2.10.0/24", "10.2.11.0/24"]

# RDS PostgreSQL - Configuration production
db_instance_class      = "db.m5.large"
db_allocated_storage   = 200
db_name                = "crm_prod_db"
db_username            = "admin"
db_multi_az            = true   # Multi-AZ OBLIGATOIRE en production
db_backup_retention    = 30     # 30 jours de backup

# ElastiCache Redis - Configuration production
elasticache_node_type    = "cache.t3.small"
elasticache_num_nodes    = 2  # Réplication pour HA
elasticache_engine_version = "7.0"

# Lambda - Configuration production
lambda_runtime              = "python3.11"
lambda_memory_size          = 1024
lambda_timeout              = 300
lambda_reserved_concurrency = 100  # Réservation élevée

# S3 et CloudFront
s3_bucket_name         = "digitrans-crm-frontend-prod"
cloudfront_price_class = "PriceClass_200"  # Plus de edge locations

# Monitoring - Complet en production
enable_detailed_monitoring = true
log_retention_days         = 90

# Alertes
alert_email = "production-alerts@camtech-solutions.cm"

# Tags additionnels
additional_tags = {
  CostCenter  = "Production"
  Team        = "Operations"
  Backup      = "true"
  Compliance  = "required"
  SLA         = "99.95"
}
