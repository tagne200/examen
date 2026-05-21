# 🚀 Guide de Démarrage Rapide - Terraform C22

## 📋 Vue d'Ensemble

Ce guide vous permet de déployer l'infrastructure DIGITRANS-CM avec Terraform en **15 minutes**.

---

## ✅ Prérequis

### 1. Installer Terraform

**Windows (Chocolatey)** :
```bash
choco install terraform
```

**Ou télécharger** : https://www.terraform.io/downloads

**Vérifier** :
```bash
terraform version
# Terraform v1.6.0 ou supérieur
```

### 2. Configurer AWS CLI

```bash
aws configure
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/...
# Default region: af-south-1
# Default output format: json
```

### 3. Vérifier les Credentials

```bash
aws sts get-caller-identity
# Doit afficher votre User ID et Account ID
```

---

## 🎯 Déploiement Rapide (Environnement Dev)

### Étape 1 : Initialiser Terraform

```bash
cd infrastructure/aws
terraform init
```

**Output attendu** :
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.31.0...

Terraform has been successfully initialized!
```

### Étape 2 : Valider la Configuration

```bash
terraform validate
```

**Output attendu** :
```
Success! The configuration is valid.
```

### Étape 3 : Planifier le Déploiement

```bash
terraform plan -var-file=../environments/dev/terraform.tfvars -out=dev.tfplan
```

**Output attendu** :
```
Plan: 25 to add, 0 to change, 0 to destroy.
```

### Étape 4 : Appliquer le Plan

```bash
terraform apply dev.tfplan
```

**Durée** : 10-15 minutes

**Output attendu** :
```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

vpc_id = "vpc-0123456789abcdef0"
rds_endpoint = "digitrans-crm-dev-db.xxxxxx.af-south-1.rds.amazonaws.com:5432"
s3_bucket_name = "digitrans-crm-frontend-dev"
cloudfront_domain_name = "d1234567890abc.cloudfront.net"
```

### Étape 5 : Récupérer les Outputs

```bash
terraform output
```

---

## 📊 Structure des Fichiers Créés

```
infrastructure/
├── aws/
│   ├── main.tf              ✅ Configuration principale
│   ├── variables.tf         ✅ Variables
│   ├── vpc.tf               ✅ VPC et réseau
│   ├── rds.tf               ✅ Base de données PostgreSQL
│   ├── s3.tf                ⏳ À créer
│   ├── lambda.tf            ⏳ À créer
│   ├── elasticache.tf       ⏳ À créer
│   ├── iam.tf               ⏳ À créer
│   └── monitoring.tf        ⏳ À créer
│
└── environments/
    ├── dev/
    │   └── terraform.tfvars ✅ Variables dev
    ├── staging/
    │   └── terraform.tfvars ✅ Variables staging
    └── production/
        └── terraform.tfvars ✅ Variables production
```

---

## 🔄 Déploiement Multi-Environnements

### Environnement Dev

```bash
cd infrastructure/aws
terraform workspace new dev
terraform plan -var-file=../environments/dev/terraform.tfvars
terraform apply -var-file=../environments/dev/terraform.tfvars
```

### Environnement Staging

```bash
terraform workspace new staging
terraform plan -var-file=../environments/staging/terraform.tfvars
terraform apply -var-file=../environments/staging/terraform.tfvars
```

### Environnement Production

```bash
terraform workspace new production
terraform plan -var-file=../environments/production/terraform.tfvars
terraform apply -var-file=../environments/production/terraform.tfvars
```

---

## 📋 Comparaison des Environnements

| Ressource | Dev | Staging | Production |
|-----------|-----|---------|------------|
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| **RDS Instance** | db.t3.micro | db.t3.small | db.m5.large |
| **RDS Multi-AZ** | ❌ Non | ❌ Non | ✅ Oui |
| **RDS Storage** | 20 GB | 50 GB | 200 GB |
| **RDS Backup** | 1 jour | 7 jours | 30 jours |
| **ElastiCache** | t3.micro (1) | t3.small (1) | t3.small (2) |
| **Lambda Memory** | 256 MB | 512 MB | 1024 MB |
| **Lambda Timeout** | 60s | 120s | 300s |
| **Monitoring** | ❌ Minimal | ✅ Activé | ✅ Complet |
| **Logs Retention** | 7 jours | 30 jours | 90 jours |
| **Coût/mois** | ~$50 | ~$100 | ~$300 |

---

## 🔍 Commandes Utiles

### Voir l'État Actuel

```bash
terraform show
```

### Lister les Ressources

```bash
terraform state list
```

### Voir une Ressource Spécifique

```bash
terraform state show aws_db_instance.main
```

### Récupérer un Output

```bash
terraform output rds_endpoint
```

### Formater le Code

```bash
terraform fmt -recursive
```

### Valider la Configuration

```bash
terraform validate
```

### Voir le Plan sans Appliquer

```bash
terraform plan -var-file=../environments/dev/terraform.tfvars
```

---

## 🧹 Nettoyage (Détruire l'Infrastructure)

### ⚠️ ATTENTION : Ceci supprime TOUTES les ressources

```bash
# Dev
terraform destroy -var-file=../environments/dev/terraform.tfvars

# Staging
terraform workspace select staging
terraform destroy -var-file=../environments/staging/terraform.tfvars

# Production (TRÈS DANGEREUX)
terraform workspace select production
terraform destroy -var-file=../environments/production/terraform.tfvars
```

---

## 🐛 Dépannage

### Erreur : "Error: No valid credential sources found"

**Solution** :
```bash
aws configure
# Configurer vos credentials AWS
```

### Erreur : "Error: creating RDS DB Instance: InvalidParameterValue"

**Solution** : Vérifier que la région `af-south-1` est activée dans votre compte AWS

### Erreur : "Error: creating S3 Bucket: BucketAlreadyExists"

**Solution** : Changer le nom du bucket dans `terraform.tfvars`

### Erreur : "Error: Insufficient permissions"

**Solution** : Vérifier que votre user IAM a les permissions nécessaires

---

## 📊 Coûts Estimés

### Environnement Dev

| Service | Configuration | Coût/mois |
|---------|---------------|-----------|
| RDS | db.t3.micro, 20GB | $15 |
| ElastiCache | t3.micro | $12 |
| NAT Gateway | 1 instance | $32 |
| S3 | 10 GB | $0.30 |
| CloudWatch | Logs | $5 |
| **Total** | - | **~$65** |

### Environnement Staging

| Service | Configuration | Coût/mois |
|---------|---------------|-----------|
| RDS | db.t3.small, 50GB | $40 |
| ElastiCache | t3.small | $25 |
| NAT Gateway | 1 instance | $32 |
| S3 | 20 GB | $0.60 |
| CloudWatch | Logs + Monitoring | $10 |
| **Total** | - | **~$108** |

### Environnement Production

| Service | Configuration | Coût/mois |
|---------|---------------|-----------|
| RDS | db.m5.large Multi-AZ, 200GB | $250 |
| ElastiCache | t3.small x2 | $50 |
| NAT Gateway | 2 instances | $64 |
| S3 | 50 GB | $1.50 |
| CloudWatch | Complet | $20 |
| **Total** | - | **~$386** |

---

## ✅ Checklist de Validation

### Avant le Déploiement

- [ ] Terraform installé (`terraform version`)
- [ ] AWS CLI configuré (`aws sts get-caller-identity`)
- [ ] Permissions IAM vérifiées
- [ ] Variables d'environnement configurées
- [ ] Budget AWS configuré

### Après le Déploiement

- [ ] VPC créé (`terraform output vpc_id`)
- [ ] RDS accessible (`terraform output rds_endpoint`)
- [ ] S3 bucket créé (`terraform output s3_bucket_name`)
- [ ] CloudFront actif (`terraform output cloudfront_domain_name`)
- [ ] Secrets Manager configuré
- [ ] CloudWatch Alarms actives

---

## 🎓 Prochaines Étapes

1. **Compléter l'infrastructure** :
   - Créer `s3.tf` (S3 + CloudFront)
   - Créer `lambda.tf` (Lambda functions)
   - Créer `elasticache.tf` (Redis)
   - Créer `iam.tf` (Rôles et permissions)
   - Créer `monitoring.tf` (CloudWatch, SNS)

2. **Configurer le backend S3** :
   - Créer un bucket pour l'état Terraform
   - Activer le versioning
   - Configurer DynamoDB pour le locking

3. **Automatiser avec CI/CD** :
   - Intégrer Terraform dans GitHub Actions
   - Automatiser `terraform plan` sur PR
   - Automatiser `terraform apply` sur merge

4. **Sécuriser** :
   - Activer le chiffrement
   - Configurer les Security Groups
   - Mettre en place les WAF rules

---

## 📚 Ressources

- **Terraform AWS Provider** : https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Terraform Best Practices** : https://www.terraform.io/docs/cloud/guides/recommended-practices
- **AWS Well-Architected** : https://aws.amazon.com/architecture/well-architected/

---

**Temps total** : 15-20 minutes  
**Difficulté** : Intermédiaire  
**Statut** : ✅ Prêt à déployer

---

**Document créé par** : CAMTECH SOLUTIONS S.A.  
**Date** : Janvier 2025  
**Version** : 1.0
