# ============================================
# DIGITRANS-CM - Déploiement ECS Fargate
# Remplace EKS : exécution conteneurisée sans gestion de nœuds
# ============================================

# ── Image ECR utilisée par le pipeline (repo : digitrans-crm-api) ──────────
locals {
  container_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/digitrans-crm-api:latest"
}

# ============================================
# Secret : URL de connexion complète à la base
# ============================================
resource "aws_secretsmanager_secret" "db_url" {
  name                    = "${local.full_name}/db/url"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, { Name = "${local.full_name}-db-url" })
}

resource "aws_secretsmanager_secret_version" "db_url" {
  secret_id     = aws_secretsmanager_secret.db_url.id
  secret_string = "postgresql://dbadmin:${random_password.db_password.result}@${aws_db_instance.main.address}:5432/${var.db_name}"
}

# ============================================
# Log Group CloudWatch pour les conteneurs
# ============================================
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.full_name}-api"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# ============================================
# Security Groups
# ============================================
# SG de l'ALB : accepte le trafic HTTP depuis Internet
resource "aws_security_group" "alb" {
  name        = "${local.full_name}-alb-sg"
  description = "Security group pour Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.full_name}-alb-sg" })
}

# SG des tâches ECS : accepte le trafic uniquement depuis l'ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "${local.full_name}-ecs-tasks-sg"
  description = "Security group pour les taches ECS Fargate"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Trafic applicatif depuis ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.full_name}-ecs-tasks-sg" })
}

# Autoriser les tâches ECS à joindre la base RDS
resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "PostgreSQL depuis les taches ECS"
}

# ============================================
# Application Load Balancer
# ============================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = merge(local.common_tags, { Name = "${var.project_name}-alb" })
}

resource "aws_lb_target_group" "api" {
  name        = "${var.project_name}-api-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # requis pour Fargate (awsvpc)

  health_check {
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# ============================================
# IAM Roles ECS
# ============================================
# Rôle d'exécution : pull ECR, écriture logs, lecture secrets
resource "aws_iam_role" "ecs_execution" {
  name = "${local.full_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Autoriser la lecture des secrets nécessaires au démarrage
resource "aws_iam_role_policy" "ecs_secrets" {
  name = "${local.full_name}-ecs-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_secretsmanager_secret.db_url.arn]
    }]
  })
}

# Rôle de la tâche (permissions applicatives runtime)
resource "aws_iam_role" "ecs_task" {
  name = "${local.full_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

# ============================================
# Cluster ECS
# ============================================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

# ============================================
# Task Definition (Fargate)
# ============================================
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.full_name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = "crm-api"
    image     = local.container_image
    essential = true

    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]

    environment = [
      { name = "AZURE_TENANT_ID", value = "dev-tenant-id" },
      { name = "AZURE_CLIENT_ID", value = "dev-client-id" },
      { name = "AZURE_CLIENT_SECRET", value = "dev-secret" },
      { name = "ENVIRONMENT", value = var.environment },
      { name = "ALLOWED_ORIGINS", value = "*" }
    ]

    secrets = [
      { name = "DATABASE_URL", valueFrom = aws_secretsmanager_secret.db_url.arn }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "crm-api"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/health')\" || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 30
    }
  }])

  tags = local.common_tags
}

# ============================================
# Service ECS
# ============================================
resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  # Ne pas bloquer l'apply en attendant des tâches saines
  # (l'image :latest est poussée par le job build-docker qui suit)
  wait_for_steady_state = false

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "crm-api"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]

  tags = local.common_tags
}

# ============================================
# Outputs
# ============================================
output "alb_dns_name" {
  description = "URL publique de l'API (via l'ALB)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = aws_ecs_service.api.name
}
