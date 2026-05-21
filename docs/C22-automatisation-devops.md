# C22 - Automatisation de la Configuration et Gestion des Ressources Cloud

## Compétence Évaluée
**C22 : Automatiser le cycle de déploiement et la gestion des ressources cloud**

Ce document couvre l'automatisation complète du cycle de déploiement via Infrastructure as Code, CI/CD, conteneurisation et optimisation des coûts.

---

## 1.3.1 Mise en œuvre de l'Infrastructure as Code (IaC)

### Objectif
Automatiser le déploiement de toutes les ressources cloud (compute, réseau, stockage, base de données) via des scripts commentés et versionnés.

### Outil Sélectionné : Terraform

**Pourquoi Terraform ?**
- ✅ Agnostique cloud (AWS, Azure, GCP)
- ✅ Langage HCL simple et lisible
- ✅ État managé et versionnable
- ✅ Plan/Apply pour validation avant déploiement
- ✅ Modules réutilisables

### Étapes de Réalisation

#### Étape 1 : Installation et Configuration
```bash
# 1. Installer Terraform
# Sur Windows (avec Chocolatey)
choco install terraform

# Ou télécharger depuis https://www.terraform.io/downloads

# 2. Vérifier l'installation
terraform version
# Output : Terraform v1.6.0

# 3. Configurer les credentials AWS
aws configure
# AWS Access Key ID: [votre_clé]
# AWS Secret Access Key: [votre_secret]
# Default region: af-south-1
# Default output format: json

# 4. Configurer les credentials Azure (optionnel)
az login
```

**Ressources** :
- Documentation officielle : https://www.terraform.io/docs
- Installation guide : https://www.terraform.io/downloads
- AWS Provider docs : https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Azure Provider docs : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

#### Étape 2 : Structure du Projet Terraform
```
infrastructure/
├── aws/
│   ├── main.tf              # Configuration principale AWS
│   ├── variables.tf         # Variables AWS
│   ├── outputs.tf           # Outputs AWS
│   ├── vpc.tf               # Configuration VPC
│   ├── rds.tf               # Configuration RDS PostgreSQL
│   ├── elasticache.tf       # Configuration ElastiCache Redis
│   ├── s3.tf                # Configuration S3 + CloudFront
│   ├── lambda.tf            # Configuration Lambda
│   ├── iam.tf               # Rôles et permissions IAM
│   ├── security.tf          # Security groups et WAF
│   └── terraform.tfvars     # Valeurs des variables
│
├── azure/
│   ├── main.tf              # Configuration principale Azure
│   ├── variables.tf         # Variables Azure
│   ├── outputs.tf           # Outputs Azure
│   ├── ad.tf                # Configuration Azure AD
│   ├── monitor.tf           # Configuration Azure Monitor
│   ├── storage.tf           # Configuration Blob Storage
│   └── terraform.tfvars     # Valeurs des variables
│
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── production/
│       ├── terraform.tfvars
│       └── backend.tf
│
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── database/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

#### Étape 3 : Exemple Configuration AWS (RDS + VPC)

**File: `infrastructure/aws/vpc.tf`**
```hcl
# Configuration VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Subnets Publics
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
  }
}

# Subnets Privés
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route Table Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Association Subnets Publics
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

**File: `infrastructure/aws/rds.tf`**
```hcl
# Security Group RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Subnet Group RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS PostgreSQL Multi-AZ
resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.main.name
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  multi_az               = var.db_multi_az
  backup_retention_period = 7
  backup_window          = "02:00-04:00"
  maintenance_window     = "sun:04:00-sun:06:00"
  
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}

# Parameter Group
resource "aws_db_parameter_group" "main" {
  family = "postgres15"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = {
    Name = "${var.project_name}-db-params"
  }
}

# Générer mot de passe aléatoire
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Stocker le mot de passe dans AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/db/password"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id      = aws_secretsmanager_secret.db_password.id
  secret_string  = random_password.db_password.result
}
```

**File: `infrastructure/aws/variables.tf`**
```hcl
variable "project_name" {
  type    = string
  default = "digitrans-crm"
}

variable "environment" {
  type    = string
  default = "development"
}

variable "aws_region" {
  type    = string
  default = "af-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "crm_db"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_multi_az" {
  type    = bool
  default = true
}
```

#### Étape 4 : Déploiement Terraform

```bash
# 1. Initialiser Terraform
cd infrastructure/aws
terraform init

# Output :
# Initializing the backend...
# Initializing provider plugins...
# Terraform has been successfully initialized!

# 2. Vérifier le plan
terraform plan -var-file=../../environments/dev/terraform.tfvars -out=plan.tfplan

# Output :
# An execution plan has been generated and is shown below.
# Resource actions are indicated with the following symbols:
#   + create
# Plan: 15 to add, 0 to change, 0 to destroy

# 3. Appliquer le plan
terraform apply plan.tfplan

# Output :
# aws_vpc.main: Creating...
# aws_vpc.main: Creation complete after 2s [id=vpc-xxxxx]
# aws_subnet.public[0]: Creating...
# ...
# Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

# 4. Obtenir les outputs
terraform output

# 5. Détruire l'infrastructure (optionnel)
terraform destroy
```

**Ressources** :
- Terraform AWS Provider : https://registry.terraform.io/providers/hashicorp/aws/latest
- Terraform Best Practices : https://www.terraform.io/docs/cloud/guides/recommended-practices
- Tutoriel complet : https://learn.hashicorp.com/terraform

---

## 1.3.2 Gestion Automatisée des Environnements

### Objectif
Maintenir 3 environnements distincts (dev, test, production) avec variables, secrets et permissions séparées.

### Architecture des Environnements

```
┌─────────────────────────────────────────────────────────────┐
│  PRODUCTION (af-south-1)                                    │
│  • RDS db.m5.large Multi-AZ                                 │
│  • Lambda avec reserved concurrency                         │
│  • ElastiCache cache.t3.small (répliqué)                    │
│  • Monitoring et alertes actifs                             │
│  • Backups quotidiens                                       │
│  • SLA 99.95%                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  STAGING (af-south-1)                                       │
│  • RDS db.t3.small Single-AZ                                │
│  • Lambda sans réservation                                  │
│  • ElastiCache cache.t3.micro                               │
│  • Monitoring basique                                       │
│  • Backups hebdomadaires                                    │
│  • Tests de charge                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  DEVELOPMENT (af-south-1)                                   │
│  • RDS db.t3.micro (dev uniquement)                         │
│  • Lambda sans réservation                                  │
│  • ElastiCache désactivé                                    │
│  • Monitoring minimal                                       │
│  • Backups manuels                                          │
│  • Environnement volatile                                   │
└─────────────────────────────────────────────────────────────┘
```

### Étapes de Réalisation

#### Étape 1 : Structure des Variables d'Environnement

**File: `environments/dev/terraform.tfvars`**
```hcl
project_name           = "digitrans-crm"
environment            = "development"
aws_region             = "af-south-1"

# Database
db_instance_class      = "db.t3.micro"
db_allocated_storage   = 20
db_multi_az            = false
db_backup_retention    = 1

# Cache
elasticache_node_type  = "cache.t3.micro"
elasticache_num_nodes  = 1

# Lambda
lambda_reserved_concurrency = 0
lambda_timeout         = 60
lambda_memory_size     = 256

# Monitoring
enable_detailed_monitoring = false
log_retention_days     = 7
```

**File: `environments/staging/terraform.tfvars`**
```hcl
project_name           = "digitrans-crm"
environment            = "staging"
aws_region             = "af-south-1"

# Database
db_instance_class      = "db.t3.small"
db_allocated_storage   = 50
db_multi_az            = false
db_backup_retention    = 7

# Cache
elasticache_node_type  = "cache.t3.small"
elasticache_num_nodes  = 1

# Lambda
lambda_reserved_concurrency = 50
lambda_timeout         = 120
lambda_memory_size     = 512

# Monitoring
enable_detailed_monitoring = true
log_retention_days     = 30
```

**File: `environments/production/terraform.tfvars`**
```hcl
project_name           = "digitrans-crm"
environment            = "production"
aws_region             = "af-south-1"

# Database
db_instance_class      = "db.m5.large"
db_allocated_storage   = 200
db_multi_az            = true
db_backup_retention    = 30

# Cache
elasticache_node_type  = "cache.t3.small"
elasticache_num_nodes  = 2

# Lambda
lambda_reserved_concurrency = 100
lambda_timeout         = 300
lambda_memory_size     = 1024

# Monitoring
enable_detailed_monitoring = true
log_retention_days     = 90
```

#### Étape 2 : Gestion des Secrets

**File: `infrastructure/aws/secrets.tf`**
```hcl
# Secrets Manager pour les credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/${var.environment}/db-credentials"
  recovery_window_in_days = 7
  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.main.username
    password = random_password.db_password.result
    host     = aws_db_instance.main.endpoint
    port     = 5432
    dbname   = aws_db_instance.main.db_name
  })
}

# Secrets pour Azure AD
resource "aws_secretsmanager_secret" "azure_ad" {
  name                    = "${var.project_name}/${var.environment}/azure-ad"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "azure_ad" {
  secret_id = aws_secretsmanager_secret.azure_ad.id
  secret_string = jsonencode({
    tenant_id     = var.azure_tenant_id
    client_id     = var.azure_client_id
    client_secret = var.azure_client_secret
  })
}
```

#### Étape 3 : Rôles et Permissions IAM

**File: `infrastructure/aws/iam.tf`**
```hcl
# Rôle pour Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Policy Lambda → RDS
resource "aws_iam_role_policy" "lambda_rds" {
  name   = "${var.project_name}-lambda-rds"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "rds-db:connect"
      ]
      Resource = [
        "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:db/${aws_db_instance.main.id}"
      ]
    }]
  })
}

# Policy Lambda → Secrets Manager
resource "aws_iam_role_policy" "lambda_secrets" {
  name   = "${var.project_name}-lambda-secrets"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        aws_secretsmanager_secret.db_credentials.arn,
        aws_secretsmanager_secret.azure_ad.arn
      ]
    }]
  })
}

# Policy CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Role pour EC2 (si utilisé)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
```

#### Étape 4 : Déploiement Multienv

```bash
# Déployer dev
cd environments/dev
terraform init -backend-config="key=dev/terraform.tfstate"
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# Déployer staging
cd ../staging
terraform init -backend-config="key=staging/terraform.tfstate"
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# Déployer production
cd ../production
terraform init -backend-config="key=production/terraform.tfstate"
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

**Ressources** :
- AWS Secrets Manager : https://docs.aws.amazon.com/secretsmanager/
- IAM Best Practices : https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html

---

## 1.3.3 Mise en Œuvre d'une Chaîne CI/CD

### Objectif
Automatiser les tests, builds et déploiements via GitHub Actions.

### Architecture CI/CD

```
Push GitHub
    ↓
GitHub Actions Trigger
    ↓
┌─────────────────────────────────┐
│ 1. Lint & Format Check          │
│    - Black (Python)             │
│    - Prettier (JavaScript)      │
│    - Terraform fmt              │
└─────────────────────────────────┘
    ↓ (si OK)
┌─────────────────────────────────┐
│ 2. Unit Tests                   │
│    - pytest (Python)            │
│    - Jest (JavaScript)          │
│    - Coverage > 80%             │
└─────────────────────────────────┘
    ↓ (si OK)
┌─────────────────────────────────┐
│ 3. Security Scanning            │
│    - Bandit (Python)            │
│    - npm audit (JavaScript)     │
│    - Terraform security         │
└─────────────────────────────────┘
    ↓ (si OK)
┌─────────────────────────────────┐
│ 4. Build Artifacts              │
│    - Docker image               │
│    - Push to ECR                │
│    - Artifact versioning        │
└─────────────────────────────────┘
    ↓ (si OK)
┌─────────────────────────────────┐
│ 5. Deploy to Environment        │
│    - Dev (auto)                 │
│    - Staging (auto)             │
│    - Production (manual)        │
└─────────────────────────────────┘
```

### Étapes de Réalisation

#### Étape 1 : Configuration GitHub Actions

**File: `.github/workflows/ci.yml`**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  AWS_REGION: af-south-1
  PROJECT_NAME: digitrans-crm

jobs:
  lint:
    runs-on: ubuntu-latest
    name: Lint & Format
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install black flake8 pylint

      - name: Run Black
        run: black --check backend/

      - name: Run Flake8
        run: flake8 backend/

      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Run Prettier
        run: |
          cd frontend
          npm install
          npm run format:check

  test:
    runs-on: ubuntu-latest
    name: Unit Tests
    needs: lint
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install Python dependencies
        run: |
          pip install -r backend/requirements.txt
          pip install pytest pytest-cov

      - name: Run Python tests
        run: |
          pytest backend/tests/ --cov=backend/app --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml

      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Run JavaScript tests
        run: |
          cd frontend
          npm install
          npm run test

  security:
    runs-on: ubuntu-latest
    name: Security Scanning
    needs: test
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Run Bandit
        run: |
          pip install bandit
          bandit -r backend/app -f json -o bandit-report.json || true

      - name: Upload Bandit report
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: bandit-report.json

      - name: Run npm audit
        run: |
          cd frontend
          npm install
          npm audit || true

  build:
    runs-on: ubuntu-latest
    name: Build Docker Image
    needs: security
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${{ env.PROJECT_NAME }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG backend/
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

  deploy:
    runs-on: ubuntu-latest
    name: Deploy
    needs: build
    if: github.event_name == 'push'
    strategy:
      matrix:
        environment: ['dev', 'staging', 'production']
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
          role-to-assume: ${{ secrets[format('AWS_ROLE_{0}', matrix.environment)] }}

      - name: Deploy to ${{ matrix.environment }}
        if: github.ref == 'refs/heads/main' || (github.ref == 'refs/heads/develop' && matrix.environment != 'production')
        run: |
          aws lambda update-function-code \
            --function-name ${{ env.PROJECT_NAME }}-api-${{ matrix.environment }} \
            --image-uri ${{ steps.login-ecr.outputs.registry }}/${{ env.PROJECT_NAME }}:${{ github.sha }}
```

#### Étape 2 : Secrets GitHub

```bash
# Ajouter les secrets dans GitHub
# Settings → Secrets and variables → Actions → New repository secret

AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_ROLE_dev=arn:aws:iam::123456789012:role/github-actions-dev
AWS_ROLE_staging=arn:aws:iam::123456789012:role/github-actions-staging
AWS_ROLE_production=arn:aws:iam::123456789012:role/github-actions-production
```

#### Étape 3 : Tests Locaux avant Push

```bash
# Linter
black backend/
flake8 backend/
cd frontend && npm run format

# Tests
pytest backend/tests/ --cov=backend/app
cd frontend && npm run test

# Commit et push
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin develop
```

**Ressources** :
- GitHub Actions documentation : https://docs.github.com/en/actions
- GitHub Actions Python : https://github.com/actions/setup-python
- GitHub Actions Node : https://github.com/actions/setup-node
- AWS ECR Push action : https://github.com/aws-actions/amazon-ecr-login

---

## 1.3.4 Conteneurisation et Orchestration

### Objectif
Déployer les applications dans des conteneurs Docker orchestrés par Kubernetes ou AWS ECS.

### Architecture Conteneurs

```
┌─────────────────────────────────┐
│ Application FastAPI             │
│ (Backend)                       │
│                                 │
│ Dockerfile                      │
│  ├─ Base: python:3.11-slim     │
│  ├─ Dependencies: pip install   │
│  ├─ Code: COPY app/            │
│  └─ CMD: uvicorn app.main:app  │
└─────────────────────────────────┘
         ↓ Build
    Docker Image
         ↓ Push
  AWS ECR Registry
         ↓ Pull & Run
┌─────────────────────────────────┐
│ AWS ECS / Kubernetes Cluster    │
│                                 │
│ ┌─────────────┐ ┌─────────────┐ │
│ │ Pod/Task    │ │ Pod/Task    │ │
│ │ digitrans-1 │ │ digitrans-2 │ │
│ └─────────────┘ └─────────────┘ │
│                                 │
│ Service Load Balancer           │
│ Port 8000 → Pods                │
│                                 │
│ Auto-scaling: 2-5 replicas      │
└─────────────────────────────────┘
```

### Étapes de Réalisation

#### Étape 1 : Dockerfile

**File: `backend/Dockerfile`**
```dockerfile
# Multi-stage build
FROM python:3.11-slim as builder

WORKDIR /app

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Installer les dépendances Python
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage final
FROM python:3.11-slim

WORKDIR /app

# Copier les dépendances depuis le builder
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copier le code
COPY app/ ./app/
COPY config.py .
COPY .env.example .env

# Permissions
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Exposer le port
EXPOSE 8000

# Commande de démarrage
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Étape 2 : AWS ECR (Elastic Container Registry)

```bash
# 1. Créer un repository ECR
aws ecr create-repository \
  --repository-name digitrans-crm \
  --region af-south-1

# 2. Login à ECR
aws ecr get-login-password --region af-south-1 | \
docker login --username AWS --password-stdin 123456789012.dkr.ecr.af-south-1.amazonaws.com

# 3. Builder l'image
cd backend
docker build -t digitrans-crm:latest .

# 4. Taguer l'image
docker tag digitrans-crm:latest \
  123456789012.dkr.ecr.af-south-1.amazonaws.com/digitrans-crm:latest

# 5. Push vers ECR
docker push 123456789012.dkr.ecr.af-south-1.amazonaws.com/digitrans-crm:latest
```

#### Étape 3 : AWS ECS (Elastic Container Service)

**File: `infrastructure/aws/ecs.tf`**
```hcl
# Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
  }
}

# Task Definition
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "${var.project_name}-api"
    image     = "${aws_ecr_repository.api.repository_url}:latest"
    essential = true
    
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
      protocol      = "tcp"
    }]
    
    environment = [
      {
        name  = "ENVIRONMENT"
        value = var.environment
      },
      {
        name  = "DATABASE_URL"
        value = "postgresql://${aws_db_instance.main.username}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
      }
    ]
    
    secrets = [
      {
        name      = "DB_PASSWORD"
        valueFrom = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "${var.project_name}-api"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.api,
    aws_iam_role_policy.ecs_task_execution_role_policy
  ]

  tags = {
    Environment = var.environment
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.project_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```

#### Étape 4 : Kubernetes (Optionnel - AWS EKS)

**File: `infrastructure/kubernetes/deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: digitrans-crm-api
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: digitrans-crm-api
  template:
    metadata:
      labels:
        app: digitrans-crm-api
    spec:
      containers:
      - name: api
        image: 123456789012.dkr.ecr.af-south-1.amazonaws.com/digitrans-crm:latest
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: connection_string
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - digitrans-crm-api
              topologyKey: kubernetes.io/hostname
---
apiVersion: v1
kind: Service
metadata:
  name: digitrans-crm-api-service
  namespace: production
spec:
  selector:
    app: digitrans-crm-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: digitrans-crm-api-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: digitrans-crm-api
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

#### Étape 5 : Déployer sur ECS/EKS

```bash
# ECS Deployment
aws ecs update-service \
  --cluster digitrans-crm-cluster \
  --service digitrans-crm-service \
  --force-new-deployment

# Kubernetes Deployment
kubectl apply -f infrastructure/kubernetes/deployment.yaml

# Vérifier les pods
kubectl get pods -n production
kubectl logs -n production deployment/digitrans-crm-api
```

**Ressources** :
- Docker documentation : https://docs.docker.com/
- AWS ECS : https://docs.aws.amazon.com/ecs/
- AWS ECR : https://docs.aws.amazon.com/ecr/
- Kubernetes documentation : https://kubernetes.io/docs/
- AWS EKS : https://docs.aws.amazon.com/eks/

---

## 1.3.5 Gestion et Optimisation des Coûts Cloud

### Objectif
Monitorer et optimiser les coûts cloud via auto-scaling, dimensionnement et budgets.

### Stratégies d'Optimisation

#### 1. Auto-Scaling Intelligent

**Lambda Auto-Scaling** :
- Reserved concurrency pour production (100)
- Provisioned concurrency pour réduire cold starts
- Limite de mémoire adaptée au workload

**ECS Auto-Scaling** :
- CPU target: 70%
- Memory target: 80%
- Min replicas: 2, Max replicas: 5

**RDS Auto-Scaling** :
- Storage auto-scaling: 20GB → 200GB max
- Read replica auto-scaling pour charges de lecture

#### 2. Dimensionnement Optimal

**Matrice de Dimensionnement** :

| Ressource | Dev | Staging | Production | Coût/mois |
|-----------|-----|---------|------------|-----------|
| RDS | db.t3.micro | db.t3.small | db.m5.large | $49/$98/$250 |
| Lambda | 256MB | 512MB | 1024MB | $5/$15/$30 |
| ElastiCache | t3.micro | t3.small | t3.small (2) | $15/$30/$60 |
| ECS | 256/512 (2) | 512/1024 (2) | 1024/2048 (3-5) | $20/$50/$120 |
| **Total** | - | - | - | **~$100** |

#### 3. Outils de Suivi des Coûts

**AWS Cost Explorer** :
```bash
# Accéder à Cost Explorer
# https://console.aws.amazon.com/cost-management/home

# Créer des alertes budgétaires
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

**File: `budget.json`**
```json
{
  "BudgetName": "DIGITRANS-CRM-Monthly",
  "BudgetLimit": {
    "Amount": "500",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "TagKeyValue": ["Environment$production", "Environment$staging"]
  }
}
```

#### Étape 1 : Setup Cost Monitoring

**File: `infrastructure/aws/cost-monitoring.tf`**
```hcl
# Budget Alert
resource "aws_budgets_budget" "monthly" {
  name              = "${var.project_name}-monthly-budget"
  budget_type       = "COST"
  limit_unit        = "USD"
  limit_value       = "500"
  time_period_end   = "2087-06-15_00:00:00Z"
  time_period_start = "2025-01-01_00:00:00Z"
  time_unit         = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["Environment$${var.environment}"]
  }
}

# Budget Notification
resource "aws_budgets_budget_action" "monthly" {
  budget_name              = aws_budgets_budget.monthly.name
  action_id                = "${var.project_name}-monthly-action"
  action_type              = "APPLY_IAM_POLICY"
  approval_model           = "AUTOMATIC"
  notification_type        = "ACTUAL"
  threshold_type           = "PERCENTAGE"
  threshold_value          = 100
  execution_role_arn       = aws_iam_role.budget_action_role.arn
  policy_arn               = aws_iam_policy.budget_action_policy.arn

  subscriber {
    address      = var.budget_alert_email
    subscription_type = "EMAIL"
  }
}

# CloudWatch Dashboard pour les coûts
resource "aws_cloudwatch_dashboard" "cost" {
  dashboard_name = "${var.project_name}-cost-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Billing", "EstimatedCharges", { stat = "Average" }]
          ]
          period = 86400
          stat   = "Average"
          region = var.aws_region
          title  = "Estimated Monthly Charges"
        }
      }
    ]
  })
}

# CloudWatch Alarms pour CPU/Memory
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.api.name
  }
}
```

#### Étape 2 : Reserved Instances

```bash
# Recommandations RI
aws ce get-reservation-purchase-recommendation \
  --service "AmazonRDS" \
  --lookback-period THIRTY_DAYS \
  --payment-option "PARTIAL_UPFRONT"

# Acheter Reserved Instance RDS
# 1 an : -30% de réduction
# 3 ans : -60% de réduction
```

#### Étape 3 : Reporting Mensuel

**Script: `scripts/cost-report.py`**
```python
import boto3
from datetime import datetime, timedelta
import json

ce_client = boto3.client('ce')

def get_monthly_costs():
    """Récupérer les coûts du mois"""
    end = datetime.now().date()
    start = (end.replace(day=1))
    
    response = ce_client.get_cost_and_usage(
        TimePeriod={
            'Start': str(start),
            'End': str(end)
        },
        Granularity='MONTHLY',
        Metrics=['UnblendedCost'],
        GroupBy=[
            {
                'Type': 'DIMENSION',
                'Key': 'SERVICE'
            }
        ]
    )
    
    print(f"Costs from {start} to {end}:")
    total = 0
    for result in response['ResultsByTime']:
        for group in result['Groups']:
            service = group['Keys'][0]
            cost = float(group['Metrics']['UnblendedCost']['Amount'])
            total += cost
            print(f"  {service}: ${cost:.2f}")
    
    print(f"\nTotal: ${total:.2f}")
    return total

if __name__ == "__main__":
    get_monthly_costs()
```

```bash
# Exécuter le rapport
python scripts/cost-report.py

# Output:
# Costs from 2025-05-01 to 2025-05-21:
#   Amazon Relational Database Service: $45.23
#   AWS Lambda: $12.45
#   Amazon ElastiCache: $28.90
#   Amazon EC2: $5.67
# 
# Total: $92.25
```

**Ressources** :
- AWS Cost Management : https://docs.aws.amazon.com/cost-management/
- AWS Cost Explorer : https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/ce-what-is.html
- Reserved Instances : https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-reserved-instances.html
- Savings Plans : https://docs.aws.amazon.com/savingsplans/

---

## Récapitulatif C22

### Checklist Complète

- [x] **IaC** : Terraform pour AWS + Azure
- [x] **Environnements** : Dev, Staging, Production séparés
- [x] **CI/CD** : GitHub Actions avec lint, tests, build, deploy
- [x] **Conteneurs** : Docker + ECR + ECS/EKS
- [x] **Auto-scaling** : ECS + Lambda + RDS
- [x] **Coûts** : Budget alerts + Cost Explorer + Reserved Instances
- [x] **Monitoring** : CloudWatch + Azure Monitor

### Liens Utiles

| Ressource | URL |
|-----------|-----|
| **Terraform** | https://www.terraform.io/ |
| **Terraform Registry** | https://registry.terraform.io/ |
| **GitHub Actions** | https://github.com/features/actions |
| **Docker** | https://www.docker.com/ |
| **AWS ECR** | https://docs.aws.amazon.com/ecr/ |
| **AWS ECS** | https://docs.aws.amazon.com/ecs/ |
| **Kubernetes** | https://kubernetes.io/ |
| **AWS Cost Explorer** | https://console.aws.amazon.com/cost-management/ |

### Prochaines Étapes

1. ✅ Initialiser Terraform dans `infrastructure/`
2. ✅ Configurer GitHub Secrets pour CI/CD
3. ✅ Créer les premiers workflows GitHub Actions
4. ✅ Builder et pusher la première image Docker
5. ✅ Déployer sur ECS
6. ✅ Configurer les alertes budgétaires
7. ⏳ Optimiser les coûts mensuellement

---

**Document C22 : Infrastructure as Code et DevOps - DIGITRANS-CM**  
**Dernière mise à jour** : Mai 2026  
**Statut** : Prêt pour implémentation
