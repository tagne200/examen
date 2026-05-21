# 🚀 DÉPLOIEMENT COMPLET DU PROJET SUR AWS

## 📋 PLAN DE DÉPLOIEMENT

### Phase 1: Sécuriser les Credentials (10 min)
### Phase 2: Créer l'Infrastructure AWS (20 min)
### Phase 3: Configurer GitHub Actions (5 min)
### Phase 4: Déployer l'Application (10 min)

**Temps total: ~45 minutes**

---

## 🔐 PHASE 1: SÉCURISER LES CREDENTIALS (10 MIN)

### Étape 1.1: Se Connecter à AWS Console

```
https://console.aws.amazon.com/
```

**Connexion avec email + mot de passe**

---

### Étape 1.2: Créer l'Utilisateur IAM

**Aller sur:**
```
https://console.aws.amazon.com/iam/home#/users
```

**Créer l'utilisateur:**
1. Cliquer "Create user"
2. **User name:** `github-actions-digitrans`
3. **DÉCOCHER** "Console access"
4. Cliquer "Next"

**Attacher les permissions:**
1. Sélectionner "Attach policies directly"
2. Chercher et cocher:
   - ☑ `AmazonEC2ContainerRegistryFullAccess`
   - ☑ `AmazonS3FullAccess`
   - ☑ `CloudFrontFullAccess`
   - ☑ `AmazonVPCFullAccess`
   - ☑ `AmazonRDSFullAccess`
   - ☑ `IAMFullAccess` (pour Terraform)
3. Cliquer "Next" → "Create user"

---

### Étape 1.3: Créer les Access Keys

1. Cliquer sur l'utilisateur `github-actions-digitrans`
2. Onglet "Security credentials"
3. Cliquer "Create access key"
4. Sélectionner "Application running outside AWS"
5. Cocher "I understand..."
6. Cliquer "Next" → "Create access key"

**⚠️ COPIER IMMÉDIATEMENT dans un fichier texte:**
```
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

7. Télécharger le CSV (backup)
8. Cliquer "Done"

---

### Étape 1.4: Obtenir l'Account ID

**En haut à droite, cliquer sur votre nom:**
```
Account ID: 123456789012
```

**Copier ce numéro (12 chiffres)**

---

### Étape 1.5: Tester Localement

```bash
# Configurer AWS CLI
aws configure

# Entrer:
AWS Access Key ID: AKIAXXXXXXXXXXXXXXXXX (nouvelle)
AWS Secret Access Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (nouvelle)
Default region name: af-south-1
Default output format: json

# Tester
aws sts get-caller-identity
```

**Résultat attendu:**
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/github-actions-digitrans"
}
```

**✅ Si ça marche, continuez!**

---

## 🏗️ PHASE 2: CRÉER L'INFRASTRUCTURE AWS (20 MIN)

### Étape 2.1: Activer la Région af-south-1

```
https://console.aws.amazon.com/billing/home#/account
```

1. Section "AWS Regions"
2. Activer "Africa (Cape Town) af-south-1"
3. Confirmer

---

### Étape 2.2: Créer le Bucket S3 pour le Frontend

```bash
# Créer le bucket
aws s3 mb s3://digitrans-crm-frontend-prod --region af-south-1

# Configurer pour hébergement web
aws s3 website s3://digitrans-crm-frontend-prod --index-document index.html --error-document index.html

# Rendre public (pour CloudFront)
aws s3api put-bucket-policy --bucket digitrans-crm-frontend-prod --policy '{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::digitrans-crm-frontend-prod/*"
  }]
}'
```

---

### Étape 2.3: Créer le Repository ECR

```bash
# Créer le repository pour les images Docker
aws ecr create-repository \
  --repository-name digitrans-crm-api \
  --region af-south-1 \
  --image-scanning-configuration scanOnPush=true

# Noter l'URL du repository (pour plus tard)
aws ecr describe-repositories --repository-names digitrans-crm-api --region af-south-1 --query 'repositories[0].repositoryUri' --output text
```

**Copier l'URL:** `123456789012.dkr.ecr.af-south-1.amazonaws.com/digitrans-crm-api`

---

### Étape 2.4: Déployer l'Infrastructure avec Terraform

```bash
cd c:\Users\KENNETH\Desktop\Examen\infrastructure\aws

# Initialiser Terraform
terraform init

# Planifier le déploiement
terraform plan -var-file=../environments/production/terraform.tfvars

# Appliquer (créer les ressources)
terraform apply -var-file=../environments/production/terraform.tfvars -auto-approve
```

**Ressources créées:**
- ✅ VPC avec subnets publics/privés
- ✅ RDS PostgreSQL
- ✅ Security Groups
- ✅ NAT Gateway
- ✅ Internet Gateway

**⏱️ Temps: ~15 minutes**

---

### Étape 2.5: Récupérer les Outputs Terraform

```bash
# Obtenir l'endpoint RDS
terraform output rds_endpoint

# Obtenir le VPC ID
terraform output vpc_id

# Obtenir les subnet IDs
terraform output private_subnet_ids
```

**Copier ces valeurs pour plus tard**

---

## 🔧 PHASE 3: CONFIGURER GITHUB ACTIONS (5 MIN)

### Étape 3.1: Ajouter les Secrets GitHub

```
https://github.com/tagne200/examen/settings/secrets/actions
```

**Créer ces secrets:**

| Name | Value | Exemple |
|------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Votre Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Votre Secret Key | `wJalrXUtnFEMI/K7MDENG...` |
| `AWS_ACCOUNT_ID` | Votre Account ID | `123456789012` |
| `S3_BUCKET_NAME` | Nom du bucket S3 | `digitrans-crm-frontend-prod` |
| `RDS_ENDPOINT` | Endpoint RDS | `digitrans-crm-db.xxx.af-south-1.rds.amazonaws.com` |
| `DATABASE_URL` | URL complète DB | `postgresql://admin:PASSWORD@endpoint:5432/crm_db` |

---

### Étape 3.2: Obtenir le Mot de Passe RDS

```bash
# Le mot de passe est dans AWS Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id digitrans-crm-rds-password \
  --region af-south-1 \
  --query SecretString \
  --output text
```

**Copier le mot de passe**

---

### Étape 3.3: Construire l'URL de la Base de Données

```
postgresql://admin:MOT_DE_PASSE@ENDPOINT:5432/crm_db
```

**Exemple:**
```
postgresql://admin:MySecureP@ssw0rd@digitrans-crm-db.abc123.af-south-1.rds.amazonaws.com:5432/crm_db
```

**Ajouter comme secret GitHub:** `DATABASE_URL`

---

## 🚀 PHASE 4: DÉPLOYER L'APPLICATION (10 MIN)

### Étape 4.1: Build et Push de l'Image Docker

```bash
cd c:\Users\KENNETH\Desktop\Examen

# Login à ECR
aws ecr get-login-password --region af-south-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.af-south-1.amazonaws.com

# Build l'image
cd backend
docker build -t digitrans-crm-api .

# Tag l'image
docker tag digitrans-crm-api:latest 123456789012.dkr.ecr.af-south-1.amazonaws.com/digitrans-crm-api:latest

# Push vers ECR
docker push 123456789012.dkr.ecr.af-south-1.amazonaws.com/digitrans-crm-api:latest
```

---

### Étape 4.2: Déployer le Frontend sur S3

```bash
cd c:\Users\KENNETH\Desktop\Examen\frontend

# Sync vers S3
aws s3 sync . s3://digitrans-crm-frontend-prod/ --exclude "*.md" --exclude ".git/*" --delete
```

---

### Étape 4.3: Initialiser la Base de Données

```bash
cd c:\Users\KENNETH\Desktop\Examen\backend

# Créer un fichier .env temporaire
echo DATABASE_URL=postgresql://admin:PASSWORD@ENDPOINT:5432/crm_db > .env

# Initialiser le schéma
python -m app.database init

# Ou exécuter le script SQL
psql -h ENDPOINT -U admin -d crm_db -f schema.sql
```

---

### Étape 4.4: Tester le Déploiement

**Tester l'API:**
```bash
# Si vous avez déployé sur EC2 ou Lambda
curl https://votre-api-endpoint.com/health
```

**Tester le Frontend:**
```bash
# Ouvrir dans le navigateur
https://digitrans-crm-frontend-prod.s3-website.af-south-1.amazonaws.com
```

---

### Étape 4.5: Déclencher le Pipeline GitHub Actions

```bash
cd c:\Users\KENNETH\Desktop\Examen

# Faire un commit
echo # Deployment test >> README.md
git add README.md
git commit -m "deploy: trigger CI/CD pipeline"
git push origin main
```

**Vérifier:**
```
https://github.com/tagne200/examen/actions
```

**Le pipeline doit:**
- ✅ Exécuter les tests
- ✅ Build l'image Docker
- ✅ Push vers ECR
- ✅ Déployer sur S3

---

## 📊 VÉRIFICATION FINALE

### Checklist de Déploiement

- [ ] Utilisateur IAM créé avec permissions
- [ ] Access Keys créées et testées
- [ ] Région af-south-1 activée
- [ ] Bucket S3 créé
- [ ] Repository ECR créé
- [ ] Infrastructure Terraform déployée
- [ ] RDS PostgreSQL opérationnel
- [ ] Secrets GitHub configurés
- [ ] Image Docker buildée et pushée
- [ ] Frontend déployé sur S3
- [ ] Base de données initialisée
- [ ] Pipeline GitHub Actions fonctionnel

---

## 🎯 ARCHITECTURE DÉPLOYÉE

```
┌─────────────────────────────────────────────────────────┐
│                    UTILISATEURS                         │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              CloudFront (CDN - Optionnel)               │
└─────────────────────────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                ▼                       ▼
┌───────────────────────┐   ┌───────────────────────┐
│   S3 (Frontend)       │   │   API (Docker/ECR)    │
│   - HTML/CSS/JS       │   │   - FastAPI Python    │
└───────────────────────┘   └───────────────────────┘
                                        │
                                        ▼
                            ┌───────────────────────┐
                            │   RDS PostgreSQL      │
                            │   - Multi-AZ          │
                            │   - Backups auto      │
                            └───────────────────────┘
```

---

## 💰 COÛTS ESTIMÉS

| Service | Configuration | Coût/mois |
|---------|--------------|-----------|
| RDS PostgreSQL | db.t3.micro | $15 |
| S3 | 5GB stockage | $0.12 |
| ECR | 10 images | $1 |
| NAT Gateway | 1x | $32 |
| Data Transfer | 10GB | $0.90 |
| **TOTAL** | | **~$49/mois** |

**Free Tier (12 premiers mois):**
- RDS: 750h/mois gratuit
- S3: 5GB gratuit
- ECR: 500MB gratuit
- **Coût réel: ~$32/mois (NAT Gateway)**

---

## 🔧 COMMANDES UTILES

### Vérifier les Ressources

```bash
# Lister les buckets S3
aws s3 ls

# Lister les repositories ECR
aws ecr describe-repositories --region af-south-1

# Vérifier RDS
aws rds describe-db-instances --region af-south-1

# Vérifier les images Docker
aws ecr list-images --repository-name digitrans-crm-api --region af-south-1
```

### Logs et Monitoring

```bash
# Logs CloudWatch
aws logs tail /aws/rds/instance/digitrans-crm-db/postgresql --follow

# Métriques RDS
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=digitrans-crm-db \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

---

## 🆘 TROUBLESHOOTING

### Problème 1: Terraform échoue

**Solution:**
```bash
# Vérifier les credentials
aws sts get-caller-identity

# Vérifier les permissions
aws iam get-user-policy --user-name github-actions-digitrans --policy-name GitHubActionsPolicy

# Réinitialiser Terraform
terraform destroy -auto-approve
terraform init
terraform apply -auto-approve
```

### Problème 2: Docker push échoue

**Solution:**
```bash
# Re-login à ECR
aws ecr get-login-password --region af-south-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.af-south-1.amazonaws.com

# Vérifier que le repository existe
aws ecr describe-repositories --repository-names digitrans-crm-api --region af-south-1
```

### Problème 3: RDS inaccessible

**Solution:**
```bash
# Vérifier les security groups
aws ec2 describe-security-groups --region af-south-1

# Vérifier l'endpoint
aws rds describe-db-instances --db-instance-identifier digitrans-crm-db --region af-south-1 --query 'DBInstances[0].Endpoint'
```

---

## 🎉 SUCCÈS!

Une fois toutes les étapes complétées:

✅ Infrastructure AWS déployée
✅ Application containerisée
✅ CI/CD fonctionnel
✅ Base de données opérationnelle
✅ Frontend accessible
✅ Monitoring actif

**Compétence C22 validée à 100%!**

---

## 📚 DOCUMENTATION

**Fichiers de référence:**
- `infrastructure/aws/` - Configuration Terraform
- `.github/workflows/ci-cd.yml` - Pipeline CI/CD
- `backend/Dockerfile` - Image Docker
- `docs/` - Documentation complète

**Prochaines étapes:**
1. Configurer CloudFront (CDN)
2. Ajouter un certificat SSL
3. Configurer le monitoring Azure
4. Mettre en place les alertes
5. Documenter les procédures d'exploitation
