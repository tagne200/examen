# ============================================
# DIGITRANS-CM - Configuration RDS PostgreSQL
# ============================================

# ============================================
# Security Group RDS
# ============================================

resource "aws_security_group" "rds" {
  name        = "${local.full_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  # Autoriser PostgreSQL depuis les subnets privés
  ingress {
    description = "PostgreSQL from private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  # Autoriser PostgreSQL depuis Lambda (si dans VPC)
  ingress {
    description = "PostgreSQL from private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-rds-sg"
    }
  )
}

# ============================================
# DB Subnet Group
# ============================================

resource "aws_db_subnet_group" "main" {
  name       = "${local.full_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-db-subnet-group"
    }
  )
}

# ============================================
# DB Parameter Group
# ============================================

resource "aws_db_parameter_group" "main" {
  family = "postgres15"
  name   = "${local.full_name}-db-params"

  # Logging
  parameter {
    name  = "log_statement"
    value = var.environment == "production" ? "all" : "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # Log queries > 1s
  }

  # Performance
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-db-params"
    }
  )
}

# ============================================
# Générer un mot de passe aléatoire
# ============================================

resource "random_password" "db_password" {
  length  = 32
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================================
# Stocker le mot de passe dans Secrets Manager
# ============================================

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.full_name}/db/password"
  recovery_window_in_days = var.environment == "production" ? 30 : 7

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-db-password"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = 5432
    dbname   = var.db_name
  })
}

# ============================================
# RDS Instance PostgreSQL
# ============================================

resource "aws_db_instance" "main" {
  identifier     = "${local.full_name}-db"
  engine         = "postgres"
  engine_version = "15"

  # Instance configuration
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  # Database configuration
  db_name  = var.db_name
  username = "dbadmin"
  password = random_password.db_password.result

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # High Availability
  multi_az = var.db_multi_az

  # Backup configuration
  backup_retention_period = var.db_backup_retention
  backup_window           = "02:00-04:00"  # 04:00-06:00 Douala time
  maintenance_window      = "sun:04:00-sun:06:00"

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = var.enable_detailed_monitoring ? 60 : 0
  monitoring_role_arn             = var.enable_detailed_monitoring ? aws_iam_role.rds_monitoring[0].arn : null

  # Parameter group
  parameter_group_name = aws_db_parameter_group.main.name

  # Snapshot configuration
  skip_final_snapshot       = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${local.full_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  # Deletion protection
  deletion_protection = var.environment == "production"

  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  # Performance Insights
  performance_insights_enabled    = var.environment == "production"
  performance_insights_retention_period = var.environment == "production" ? 7 : 0

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-db"
    }
  )

  lifecycle {
    ignore_changes = [
      password,  # Ignore password changes
    ]
  }
}

# ============================================
# IAM Role pour RDS Enhanced Monitoring
# ============================================

resource "aws_iam_role" "rds_monitoring" {
  count = var.enable_detailed_monitoring ? 1 : 0
  name  = "${local.full_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.full_name}-rds-monitoring-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.enable_detailed_monitoring ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ============================================
# CloudWatch Alarms pour RDS
# ============================================

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.full_name}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${local.full_name}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000000000"  # 5 GB
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "${local.full_name}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS database connections"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = local.common_tags
}
