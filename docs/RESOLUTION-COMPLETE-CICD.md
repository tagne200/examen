# Résolution Erreur AWS Token + Pipeline CI/CD Complet

## Problème: "The security token included in the request is invalid"

### Solution 1: Vérifier les Secrets GitHub

```bash
# Aller dans: Settings > Secrets and variables > Actions
# Vérifier que ces secrets existent:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_ACCOUNT_ID
S3_BUCKET_NAME
CLOUDFRONT_DISTRIBUTION_ID
```

### Solution 2: Créer un nouvel utilisateur IAM

```bash
# 1. Créer utilisateur IAM
aws iam create-user --user-name github-actions-digitrans

# 2. Attacher les politiques nécessaires
aws iam attach-user-policy --user-name github-actions-digitrans --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam attach-user-policy --user-name github-actions-digitrans --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-user-policy --user-name github-actions-digitrans --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-user-policy --user-name github-actions-digitrans --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess

# 3. Créer les access keys
aws iam create-access-key --user-name github-actions-digitrans
```

### Solution 3: Politique IAM Personnalisée

Créer une politique avec les permissions minimales:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "eks:*",
        "s3:*",
        "cloudfront:CreateInvalidation",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

## Pipeline CI/CD Complet - Résumé

### Architecture du Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                    GITHUB PUSH (main)                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 1: Tests Backend (PostgreSQL + pytest)                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 2: Linting & Security (flake8, bandit, safety)        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 3: Terraform Infrastructure (VPC, RDS, EKS, ECR)       │
│  ✓ terraform init                                           │
│  ✓ terraform plan                                           │
│  ✓ terraform apply                                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 4: Build & Push Docker (ECR)                           │
│  ✓ docker build                                             │
│  ✓ docker tag                                               │
│  ✓ docker push to ECR                                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 5: Deploy Kubernetes (EKS)                             │
│  ✓ kubectl apply deployment                                 │
│  ✓ kubectl rollout status                                   │
│  ✓ Deploy frontend to S3                                    │
│  ✓ Invalidate CloudFront                                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  JOB 6: Notification                                        │
└─────────────────────────────────────────────────────────────┘
```

### Ressources Créées

**Infrastructure (Terraform):**
- VPC avec subnets publics/privés Multi-AZ
- RDS PostgreSQL 15.4 avec backups automatiques
- EKS Cluster Kubernetes 1.28
- ECR Repository pour images Docker
- Security Groups et IAM Roles

**Conteneurisation (Docker):**
- Image Docker de l'API Python/FastAPI
- Push automatique vers Amazon ECR
- Tagging avec SHA du commit

**Orchestration (Kubernetes):**
- Deployment avec 3 replicas
- Service LoadBalancer
- HorizontalPodAutoscaler (2-10 pods)
- Health checks (liveness + readiness)

### Secrets Requis

```
AWS_ACCESS_KEY_ID          # Access key IAM user
AWS_SECRET_ACCESS_KEY      # Secret key IAM user
AWS_ACCOUNT_ID             # ID du compte AWS (12 chiffres)
S3_BUCKET_NAME             # Nom du bucket S3 frontend
CLOUDFRONT_DISTRIBUTION_ID # ID de la distribution CloudFront
```

### Commandes de Vérification

```bash
# Vérifier le cluster EKS
aws eks describe-cluster --name digitrans-crm-cluster --region af-south-1

# Vérifier les images ECR
aws ecr describe-images --repository-name digitrans-crm-api --region af-south-1

# Vérifier les pods Kubernetes
kubectl get pods -n digitrans-crm

# Vérifier le service
kubectl get svc -n digitrans-crm

# Vérifier l'autoscaling
kubectl get hpa -n digitrans-crm
```

### Coûts Estimés (Production)

| Service | Configuration | Coût/mois |
|---------|--------------|-----------|
| EKS Cluster | 1 cluster | $73 |
| EC2 (nodes) | 3x t3.medium | $95 |
| RDS PostgreSQL | db.m5.large Multi-AZ | $280 |
| ECR | 10 images | $1 |
| NAT Gateway | 2x Multi-AZ | $65 |
| **TOTAL** | | **~$514/mois** |

### Validation C22

✅ **CI/CD**: GitHub Actions avec 6 jobs automatisés
✅ **Tests automatisés**: pytest + coverage
✅ **Conteneurisation**: Docker + ECR
✅ **Orchestration**: Kubernetes (EKS) avec autoscaling
✅ **Infrastructure as Code**: Terraform multi-environnements
✅ **Sécurité**: Scanning avec bandit + safety

## Prochaines Étapes

1. **Configurer les secrets GitHub** avec les credentials AWS
2. **Créer le bucket S3** pour le frontend
3. **Créer la distribution CloudFront**
4. **Push vers main** pour déclencher le pipeline
5. **Vérifier les logs** dans GitHub Actions
