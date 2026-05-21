# C21 - Guide de Mise en Œuvre Pratique

## Objectif
Ce document détaille la mise en œuvre concrète de l'architecture cloud pour le projet DIGITRANS-CM CRM.

---

## ÉTAPE 1 : Préparation de l'Environnement

### 1.1 Prérequis

**Comptes Cloud** :
- [ ] Compte AWS avec accès région af-south-1
- [ ] Compte Azure avec Azure AD
- [ ] Carte bancaire pour validation (pas de charges si Free Tier)

**Outils Locaux** :
```bash
# Installer AWS CLI
# Windows
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Vérifier
aws --version

# Installer Azure CLI
# Windows
winget install Microsoft.AzureCLI

# Vérifier
az --version

# Installer Terraform (optionnel)
choco install terraform

# Installer PostgreSQL client
choco install postgresql
```

### 1.2 Configuration des Credentials

**AWS** :
```bash
aws configure
# AWS Access Key ID: AKIAXXXXXXXXXXXXXXXX
# AWS Secret Access Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# Default region name: af-south-1
# Default output format: json

# Tester
aws sts get-caller-identity
```

**Azure** :
```bash
az login
# Ouvre le navigateur pour authentification

# Lister les subscriptions
az account list --output table

# Définir la subscription par défaut
az account set --subscription "Votre Subscription ID"

# Tester
az account show
```

---

## ÉTAPE 2 : Déploiement de l'Infrastructure AWS

### 2.1 Créer le VPC et les Subnets

**Option 1 : Via Console AWS** (Recommandé pour débutants)

1. Aller dans **VPC** → **Create VPC**
2. Sélectionner **VPC and more**
3. Configuration :
   ```
   Name: digitrans-crm-vpc
   IPv4 CIDR: 10.0.0.0/16
   Number of AZs: 2
   Number of public subnets: 2
   Number of private subnets: 2
   NAT gateways: 1 per AZ (ou None pour économiser)
   VPC endpoints: None
   ```
4. Cliquer sur **Create VPC**

**Option 2 : Via AWS CLI**

```bash
# Créer le VPC
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=digitrans-crm-vpc}]' \
    --region af-south-1 \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: $VPC_ID"

# Créer les subnets publics
SUBNET_PUBLIC_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone af-south-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=digitrans-public-a}]' \
    --query 'Subnet.SubnetId' \
    --output text)

SUBNET_PUBLIC_B=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone af-south-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=digitrans-public-b}]' \
    --query 'Subnet.SubnetId' \
    --output text)

# Créer les subnets privés
SUBNET_PRIVATE_A=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.11.0/24 \
    --availability-zone af-south-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=digitrans-private-a}]' \
    --query 'Subnet.SubnetId' \
    --output text)

SUBNET_PRIVATE_B=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.12.0/24 \
    --availability-zone af-south-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=digitrans-private-b}]' \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Subnets créés:"
echo "Public A: $SUBNET_PUBLIC_A"
echo "Public B: $SUBNET_PUBLIC_B"
echo "Private A: $SUBNET_PRIVATE_A"
echo "Private B: $SUBNET_PRIVATE_B"
```

### 2.2 Créer le Security Group pour RDS

```bash
# Créer le security group
SG_RDS=$(aws ec2 create-security-group \
    --group-name digitrans-rds-sg \
    --description "Security group for DIGITRANS CRM RDS" \
    --vpc-id $VPC_ID \
    --region af-south-1 \
    --query 'GroupId' \
    --output text)

echo "Security Group RDS: $SG_RDS"

# Autoriser PostgreSQL depuis le VPC
aws ec2 authorize-security-group-ingress \
    --group-id $SG_RDS \
    --protocol tcp \
    --port 5432 \
    --cidr 10.0.0.0/16 \
    --region af-south-1

# Autoriser depuis votre IP (pour tests)
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_RDS \
    --protocol tcp \
    --port 5432 \
    --cidr $MY_IP/32 \
    --region af-south-1

echo "Security Group configuré"
```

### 2.3 Créer le Subnet Group pour RDS

```bash
aws rds create-db-subnet-group \
    --db-subnet-group-name digitrans-rds-subnet-group \
    --db-subnet-group-description "Subnet group for DIGITRANS CRM RDS" \
    --subnet-ids $SUBNET_PRIVATE_A $SUBNET_PRIVATE_B \
    --region af-south-1

echo "Subnet Group créé"
```

### 2.4 Créer l'Instance RDS PostgreSQL

**Via Console AWS** (Recommandé) :

1. Aller dans **RDS** → **Create database**
2. Configuration :
   ```
   Engine: PostgreSQL 15.x
   Template: Free tier (ou Dev/Test)
   
   DB instance identifier: digitrans-crm-db
   Master username: admin
   Master password: [Générer un mot de passe fort]
   
   DB instance class: db.t3.micro (Free tier) ou db.t3.small
   Storage: 20 GB gp3
   Storage autoscaling: Enabled (max 100 GB)
   
   VPC: digitrans-crm-vpc
   Subnet group: digitrans-rds-subnet-group
   Public access: No
   VPC security group: digitrans-rds-sg
   
   Database name: crm_db
   Port: 5432
   
   Backup retention: 7 days
   Backup window: 02:00-04:00 UTC
   
   Encryption: Enabled
   
   Multi-AZ: Yes (pour production)
   ```
3. Cliquer sur **Create database**
4. Attendre 10-15 minutes

**Via AWS CLI** :

```bash
aws rds create-db-instance \
    --db-instance-identifier digitrans-crm-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.4 \
    --master-username admin \
    --master-user-password "VotreMotDePasseSecurise123!" \
    --allocated-storage 20 \
    --storage-type gp3 \
    --storage-encrypted \
    --vpc-security-group-ids $SG_RDS \
    --db-subnet-group-name digitrans-rds-subnet-group \
    --db-name crm_db \
    --backup-retention-period 7 \
    --preferred-backup-window 02:00-04:00 \
    --preferred-maintenance-window sun:04:00-sun:06:00 \
    --multi-az \
    --region af-south-1 \
    --tags Key=Project,Value=DIGITRANS-CM Key=Environment,Value=Production

echo "RDS instance en cours de création..."
echo "Cela peut prendre 10-15 minutes"

# Attendre que l'instance soit disponible
aws rds wait db-instance-available \
    --db-instance-identifier digitrans-crm-db \
    --region af-south-1

echo "RDS instance créée et disponible!"
```

**Récupérer l'endpoint** :

```bash
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier digitrans-crm-db \
    --region af-south-1 \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

echo "RDS Endpoint: $RDS_ENDPOINT"
echo "Connection string: postgresql://admin:VotreMotDePasse@$RDS_ENDPOINT:5432/crm_db"
```

**Tester la connexion** :

```bash
psql -h $RDS_ENDPOINT -U admin -d crm_db
# Entrer le mot de passe
# Si connecté : \l pour lister les bases
# \q pour quitter
```

### 2.5 Créer le Bucket S3 pour le Frontend

```bash
# Créer le bucket
aws s3 mb s3://digitrans-crm-frontend --region af-south-1

# Activer le versioning
aws s3api put-bucket-versioning \
    --bucket digitrans-crm-frontend \
    --versioning-configuration Status=Enabled

# Activer le chiffrement
aws s3api put-bucket-encryption \
    --bucket digitrans-crm-frontend \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

# Configurer le site web statique
aws s3 website s3://digitrans-crm-frontend \
    --index-document index.html \
    --error-document index.html

# Configurer la politique publique (via CloudFront uniquement)
cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::digitrans-crm-frontend/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy \
    --bucket digitrans-crm-frontend \
    --policy file://bucket-policy.json

echo "Bucket S3 créé et configuré"
```

### 2.6 Créer la Distribution CloudFront

**Via Console AWS** :

1. Aller dans **CloudFront** → **Create distribution**
2. Configuration :
   ```
   Origin domain: digitrans-crm-frontend.s3.af-south-1.amazonaws.com
   Origin access: Origin access control (OAC)
   
   Viewer protocol policy: Redirect HTTP to HTTPS
   Allowed HTTP methods: GET, HEAD, OPTIONS
   Cache policy: CachingOptimized
   
   Price class: Use only North America, Europe, Asia, Middle East, and Africa
   
   Alternate domain names (CNAMEs): crm.agrocam.cm (si domaine)
   SSL certificate: Default CloudFront certificate (ou ACM)
   
   Default root object: index.html
   ```
3. Cliquer sur **Create distribution**
4. Attendre 10-15 minutes

**Récupérer l'URL CloudFront** :

```bash
CLOUDFRONT_URL=$(aws cloudfront list-distributions \
    --query 'DistributionList.Items[0].DomainName' \
    --output text)

echo "CloudFront URL: https://$CLOUDFRONT_URL"
```

### 2.7 Créer l'Instance ElastiCache Redis (Optionnel)

```bash
# Créer le subnet group
aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name digitrans-redis-subnet-group \
    --cache-subnet-group-description "Subnet group for DIGITRANS Redis" \
    --subnet-ids $SUBNET_PRIVATE_A $SUBNET_PRIVATE_B \
    --region af-south-1

# Créer le security group
SG_REDIS=$(aws ec2 create-security-group \
    --group-name digitrans-redis-sg \
    --description "Security group for DIGITRANS Redis" \
    --vpc-id $VPC_ID \
    --region af-south-1 \
    --query 'GroupId' \
    --output text)

# Autoriser Redis depuis le VPC
aws ec2 authorize-security-group-ingress \
    --group-id $SG_REDIS \
    --protocol tcp \
    --port 6379 \
    --cidr 10.0.0.0/16 \
    --region af-south-1

# Créer le cluster Redis
aws elasticache create-cache-cluster \
    --cache-cluster-id digitrans-redis \
    --cache-node-type cache.t3.micro \
    --engine redis \
    --engine-version 7.0 \
    --num-cache-nodes 1 \
    --cache-subnet-group-name digitrans-redis-subnet-group \
    --security-group-ids $SG_REDIS \
    --region af-south-1

echo "Redis cluster en cours de création..."
```

---

## ÉTAPE 3 : Configuration Azure

### 3.1 Créer l'App Registration Azure AD

**Via Portail Azure** :

1. Aller dans **Azure Active Directory** → **App registrations** → **New registration**
2. Configuration :
   ```
   Name: DIGITRANS-CRM
   Supported account types: Accounts in this organizational directory only
   Redirect URI: 
     - Web: https://votre-cloudfront-url.cloudfront.net/callback
     - Web: http://localhost:3000/callback (dev)
   ```
3. Cliquer sur **Register**
4. Noter l'**Application (client) ID** et le **Directory (tenant) ID**

**Créer un Client Secret** :

1. Aller dans **Certificates & secrets** → **New client secret**
2. Description : `DIGITRANS-CRM-Secret`
3. Expires : 24 months
4. Cliquer sur **Add**
5. **IMPORTANT** : Copier immédiatement la valeur du secret (ne sera plus visible)

**Configurer les Permissions** :

1. Aller dans **API permissions** → **Add a permission**
2. Sélectionner **Microsoft Graph** → **Delegated permissions**
3. Ajouter :
   - `User.Read`
   - `email`
   - `openid`
   - `profile`
4. Cliquer sur **Grant admin consent**

**Via Azure CLI** :

```bash
# Créer l'app registration
APP_ID=$(az ad app create \
    --display-name "DIGITRANS-CRM" \
    --sign-in-audience AzureADMyOrg \
    --web-redirect-uris "https://votre-cloudfront-url.cloudfront.net/callback" "http://localhost:3000/callback" \
    --query appId \
    --output tsv)

echo "Application ID: $APP_ID"

# Récupérer le Tenant ID
TENANT_ID=$(az account show --query tenantId --output tsv)
echo "Tenant ID: $TENANT_ID"

# Créer un secret
SECRET=$(az ad app credential reset \
    --id $APP_ID \
    --append \
    --query password \
    --output tsv)

echo "Client Secret: $SECRET"
echo "IMPORTANT: Sauvegarder ce secret immédiatement!"

# Ajouter les permissions
az ad app permission add \
    --id $APP_ID \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope

# Accorder le consentement admin
az ad app permission admin-consent --id $APP_ID
```

### 3.2 Créer le Log Analytics Workspace

```bash
# Créer un resource group
az group create \
    --name digitrans-crm-rg \
    --location southafricanorth

# Créer le workspace
az monitor log-analytics workspace create \
    --resource-group digitrans-crm-rg \
    --workspace-name digitrans-crm-logs \
    --location southafricanorth

# Récupérer l'ID et la clé
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --resource-group digitrans-crm-rg \
    --workspace-name digitrans-crm-logs \
    --query customerId \
    --output tsv)

WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group digitrans-crm-rg \
    --workspace-name digitrans-crm-logs \
    --query primarySharedKey \
    --output tsv)

echo "Workspace ID: $WORKSPACE_ID"
echo "Workspace Key: $WORKSPACE_KEY"
```

---

## ÉTAPE 4 : Déploiement de l'Application

### 4.1 Configurer les Variables d'Environnement

**Backend (.env)** :

```bash
cd backend
cat > .env << EOF
# Database
DATABASE_URL=postgresql://admin:VotreMotDePasse@$RDS_ENDPOINT:5432/crm_db

# Azure AD
AZURE_TENANT_ID=$TENANT_ID
AZURE_CLIENT_ID=$APP_ID
AZURE_CLIENT_SECRET=$SECRET

# Azure Monitor
AZURE_WORKSPACE_ID=$WORKSPACE_ID
AZURE_WORKSPACE_KEY=$WORKSPACE_KEY

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
ENVIRONMENT=production
SECRET_KEY=$(openssl rand -hex 32)

# CORS
ALLOWED_ORIGINS=https://$CLOUDFRONT_URL

# Redis (si configuré)
REDIS_URL=redis://digitrans-redis.xxxxxx.cache.amazonaws.com:6379/0
EOF

echo "Fichier .env créé"
```

**Frontend (config.js)** :

```javascript
const CONFIG = {
    API_URL: 'https://votre-api-url.amazonaws.com/api',
    AZURE_CLIENT_ID: '$APP_ID',
    AZURE_TENANT_ID: '$TENANT_ID',
    AZURE_REDIRECT_URI: 'https://$CLOUDFRONT_URL/callback',
    // ...
};
```

### 4.2 Initialiser la Base de Données

```bash
cd backend

# Activer l'environnement virtuel
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Installer les dépendances
pip install -r requirements.txt

# Initialiser la base de données
python -m app.database init

# Vérifier
psql -h $RDS_ENDPOINT -U admin -d crm_db -c "\dt"
```

### 4.3 Déployer le Frontend sur S3

```bash
cd frontend

# Uploader les fichiers
aws s3 sync . s3://digitrans-crm-frontend/ \
    --exclude "*.md" \
    --exclude ".git/*" \
    --exclude "README.md" \
    --region af-south-1

# Invalider le cache CloudFront
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
    --query 'DistributionList.Items[0].Id' \
    --output text)

aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*"

echo "Frontend déployé sur: https://$CLOUDFRONT_URL"
```

### 4.4 Déployer le Backend (Option Lambda)

```bash
cd backend

# Créer le package de déploiement
mkdir package
pip install -r requirements.txt -t package/
cp -r app package/
cd package
zip -r ../deployment-package.zip .
cd ..

# Créer le rôle IAM pour Lambda
aws iam create-role \
    --role-name digitrans-lambda-role \
    --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "lambda.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

# Attacher les politiques
aws iam attach-role-policy \
    --role-name digitrans-lambda-role \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole

# Créer la fonction Lambda
aws lambda create-function \
    --function-name digitrans-crm-api \
    --runtime python3.11 \
    --role arn:aws:iam::ACCOUNT_ID:role/digitrans-lambda-role \
    --handler app.main.handler \
    --zip-file fileb://deployment-package.zip \
    --timeout 30 \
    --memory-size 512 \
    --region af-south-1 \
    --environment Variables="{
        DATABASE_URL=$DATABASE_URL,
        AZURE_TENANT_ID=$TENANT_ID,
        AZURE_CLIENT_ID=$APP_ID
    }"

echo "Lambda function créée"
```

---

## ÉTAPE 5 : Validation et Tests

### 5.1 Tests de Connectivité

```bash
# Tester la base de données
psql -h $RDS_ENDPOINT -U admin -d crm_db -c "SELECT version();"

# Tester le frontend
curl -I https://$CLOUDFRONT_URL

# Tester l'API (si déployée)
curl https://votre-api-url.amazonaws.com/health
```

### 5.2 Tests Fonctionnels

```bash
# Créer un client de test
curl -X POST "https://votre-api-url.amazonaws.com/api/clients" \
  -H "Authorization: Bearer dev-token" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Restaurant Test",
    "email": "test@example.cm",
    "ville": "Douala",
    "statut": "actif"
  }'

# Récupérer les clients
curl "https://votre-api-url.amazonaws.com/api/clients" \
  -H "Authorization: Bearer dev-token"
```

### 5.3 Vérifier les Logs

```bash
# Logs RDS
aws rds describe-db-log-files \
    --db-instance-identifier digitrans-crm-db \
    --region af-south-1

# Logs Lambda
aws logs tail /aws/lambda/digitrans-crm-api --follow

# Logs Azure Monitor
az monitor log-analytics query \
    --workspace $WORKSPACE_ID \
    --analytics-query "AppLogs | where TimeGenerated > ago(1h) | order by TimeGenerated desc" \
    --output table
```

---

## ÉTAPE 6 : Monitoring et Alertes

### 6.1 Créer des Alertes Azure Monitor

```bash
# Créer une alerte pour erreurs API
az monitor metrics alert create \
    --name "API-High-Error-Rate" \
    --resource-group digitrans-crm-rg \
    --condition "avg Percentage CPU > 80" \
    --description "Alert when API error rate exceeds 5%" \
    --evaluation-frequency 5m \
    --window-size 15m \
    --severity 2
```

### 6.2 Créer un Dashboard

Via le portail Azure :
1. **Azure Monitor** → **Dashboards** → **New dashboard**
2. Ajouter des widgets :
   - Graphique de requêtes/min
   - Temps de réponse moyen
   - Taux d'erreur
   - Utilisation CPU/RAM

---

## ÉTAPE 7 : Sécurisation

### 7.1 Activer AWS CloudTrail

```bash
aws cloudtrail create-trail \
    --name digitrans-audit-trail \
    --s3-bucket-name digitrans-audit-logs \
    --is-multi-region-trail \
    --region af-south-1

aws cloudtrail start-logging \
    --name digitrans-audit-trail
```

### 7.2 Activer AWS GuardDuty

```bash
aws guardduty create-detector \
    --enable \
    --region af-south-1
```

### 7.3 Configurer les Backups

```bash
# Vérifier les backups RDS
aws rds describe-db-snapshots \
    --db-instance-identifier digitrans-crm-db \
    --region af-south-1

# Créer un snapshot manuel
aws rds create-db-snapshot \
    --db-instance-identifier digitrans-crm-db \
    --db-snapshot-identifier digitrans-crm-manual-snapshot-$(date +%Y%m%d) \
    --region af-south-1
```

---

## ÉTAPE 8 : Documentation

### 8.1 Documenter les Ressources Créées

Créer un fichier `infrastructure-inventory.md` :

```markdown
# Inventaire Infrastructure DIGITRANS-CM

## AWS Resources (af-south-1)

### VPC
- VPC ID: vpc-xxxxxxxxx
- CIDR: 10.0.0.0/16

### RDS
- Instance: digitrans-crm-db
- Endpoint: digitrans-crm-db.xxxxxx.af-south-1.rds.amazonaws.com
- Type: db.t3.small
- Multi-AZ: Yes

### S3
- Bucket: digitrans-crm-frontend
- CloudFront: dxxxxxxxxxx.cloudfront.net

### Lambda
- Function: digitrans-crm-api
- Runtime: Python 3.11

## Azure Resources

### Azure AD
- Tenant ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
- App ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

### Azure Monitor
- Workspace: digitrans-crm-logs
- Resource Group: digitrans-crm-rg
```

---

## CONCLUSION

✅ Infrastructure AWS déployée  
✅ Azure AD configuré  
✅ Application déployée  
✅ Monitoring activé  
✅ Sécurité configurée  

**Prochaines étapes** :
1. Tests de charge
2. Optimisations
3. Documentation utilisateur
4. Formation équipe

---

**Document créé par** : [Votre Nom]  
**Date** : Janvier 2025  
**Version** : 1.0
