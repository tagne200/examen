# Guide de Déploiement - Module CRM DIGITRANS-CM

## Prérequis

### Comptes Cloud
- ✅ Compte AWS avec accès région af-south-1 (Afrique du Sud)
- ✅ Compte Azure avec Azure AD configuré
- ✅ Droits administrateur sur les deux plateformes

### Outils Locaux
```bash
# Python 3.11+
python --version

# AWS CLI
aws --version

# Azure CLI
az --version

# Terraform (optionnel)
terraform --version

# Git
git --version
```

---

## Étape 1 : Configuration AWS

### 1.1 Configuration des Credentials
```bash
aws configure
# AWS Access Key ID: [Votre clé]
# AWS Secret Access Key: [Votre secret]
# Default region name: af-south-1
# Default output format: json
```

### 1.2 Création de la Base de Données RDS

**Via Console AWS** :
1. Aller dans RDS → Create database
2. Configuration :
   - Engine : PostgreSQL 15
   - Template : Free tier (dev) ou Production
   - DB instance identifier : `digitrans-crm-db`
   - Master username : `admin`
   - Master password : [Générer un mot de passe fort]
   - Instance class : db.t3.micro (dev) ou db.t3.small (prod)
   - Storage : 20 GB SSD
   - Multi-AZ : Yes (production)
   - VPC : Default ou créer un nouveau
   - Public access : No
   - VPC security group : Créer nouveau `digitrans-crm-sg`
   - Database name : `crm_db`

3. Règles Security Group :
   - Inbound : PostgreSQL (5432) depuis votre IP ou VPC
   - Outbound : All traffic

**Via AWS CLI** :
```bash
aws rds create-db-instance \
    --db-instance-identifier digitrans-crm-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.3 \
    --master-username admin \
    --master-user-password VotreMotDePasseSecurise123! \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxxxxxx \
    --db-name crm_db \
    --backup-retention-period 7 \
    --region af-south-1
```

**Récupérer l'endpoint** :
```bash
aws rds describe-db-instances \
    --db-instance-identifier digitrans-crm-db \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text
```

### 1.3 Création du Bucket S3 pour le Frontend

```bash
# Créer le bucket
aws s3 mb s3://digitrans-crm-frontend --region af-south-1

# Activer le site web statique
aws s3 website s3://digitrans-crm-frontend \
    --index-document index.html \
    --error-document error.html

# Configurer la politique publique
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::digitrans-crm-frontend/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy \
    --bucket digitrans-crm-frontend \
    --policy file://bucket-policy.json
```

### 1.4 Configuration CloudFront (CDN)

**Via Console AWS** :
1. CloudFront → Create Distribution
2. Origin domain : `digitrans-crm-frontend.s3.af-south-1.amazonaws.com`
3. Viewer protocol policy : Redirect HTTP to HTTPS
4. Allowed HTTP methods : GET, HEAD, OPTIONS
5. Cache policy : CachingOptimized
6. Create distribution

**Récupérer l'URL CloudFront** :
```bash
aws cloudfront list-distributions \
    --query 'DistributionList.Items[0].DomainName' \
    --output text
```

---

## Étape 2 : Configuration Azure

### 2.1 Connexion Azure CLI
```bash
az login
az account set --subscription "Votre Subscription ID"
```

### 2.2 Création Azure AD App Registration

```bash
# Créer l'application
az ad app create \
    --display-name "DIGITRANS-CRM" \
    --sign-in-audience AzureADMyOrg \
    --web-redirect-uris "https://votre-cloudfront-url.cloudfront.net/callback" \
                        "http://localhost:3000/callback"

# Récupérer l'Application (client) ID
APP_ID=$(az ad app list --display-name "DIGITRANS-CRM" --query '[0].appId' -o tsv)
echo "Application ID: $APP_ID"

# Créer un secret client
az ad app credential reset --id $APP_ID --append
# Sauvegarder le secret affiché !

# Récupérer le Tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "Tenant ID: $TENANT_ID"
```

**Configuration des permissions** :
```bash
# Ajouter les permissions Microsoft Graph
az ad app permission add \
    --id $APP_ID \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope

# Accorder le consentement admin
az ad app permission admin-consent --id $APP_ID
```

### 2.3 Configuration Azure Monitor

```bash
# Créer un Resource Group
az group create \
    --name digitrans-crm-rg \
    --location southafricanorth

# Créer un Log Analytics Workspace
az monitor log-analytics workspace create \
    --resource-group digitrans-crm-rg \
    --workspace-name digitrans-crm-logs \
    --location southafricanorth

# Récupérer l'ID du workspace
WORKSPACE_ID=$(az monitor log-analytics workspace show \
    --resource-group digitrans-crm-rg \
    --workspace-name digitrans-crm-logs \
    --query customerId -o tsv)

# Récupérer la clé
WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group digitrans-crm-rg \
    --workspace-name digitrans-crm-logs \
    --query primarySharedKey -o tsv)
```

---

## Étape 3 : Déploiement Backend

### 3.1 Configuration de l'Environnement

Créer le fichier `.env` dans `backend/` :
```bash
# Database
DATABASE_URL=postgresql://admin:VotreMotDePasse@digitrans-crm-db.xxxxxx.af-south-1.rds.amazonaws.com:5432/crm_db

# Azure AD
AZURE_TENANT_ID=votre-tenant-id
AZURE_CLIENT_ID=votre-client-id
AZURE_CLIENT_SECRET=votre-client-secret

# Azure Monitor
AZURE_WORKSPACE_ID=votre-workspace-id
AZURE_WORKSPACE_KEY=votre-workspace-key

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
ENVIRONMENT=production
SECRET_KEY=generer-une-cle-secrete-aleatoire-ici

# CORS
ALLOWED_ORIGINS=https://votre-cloudfront-url.cloudfront.net
```

### 3.2 Installation des Dépendances

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt
```

### 3.3 Initialisation de la Base de Données

```bash
# Créer les tables
python -m app.database init

# Ou manuellement avec psql
psql -h digitrans-crm-db.xxxxxx.af-south-1.rds.amazonaws.com \
     -U admin -d crm_db -f scripts/schema.sql
```

### 3.4 Déploiement sur AWS Lambda (Option 1)

```bash
# Créer le package de déploiement
cd backend
pip install -r requirements.txt -t package/
cp -r app package/
cd package
zip -r ../deployment-package.zip .

# Créer la fonction Lambda
aws lambda create-function \
    --function-name digitrans-crm-api \
    --runtime python3.11 \
    --role arn:aws:iam::ACCOUNT_ID:role/lambda-execution-role \
    --handler app.main.handler \
    --zip-file fileb://../deployment-package.zip \
    --timeout 30 \
    --memory-size 512 \
    --region af-south-1 \
    --environment Variables="{DATABASE_URL=$DATABASE_URL,AZURE_TENANT_ID=$AZURE_TENANT_ID}"
```

### 3.5 Déploiement sur EC2 (Option 2)

```bash
# Lancer une instance EC2
aws ec2 run-instances \
    --image-id ami-xxxxxxxxx \
    --instance-type t3.small \
    --key-name votre-keypair \
    --security-group-ids sg-xxxxxxxxx \
    --region af-south-1

# Se connecter à l'instance
ssh -i votre-keypair.pem ubuntu@ec2-ip-address

# Sur l'instance
sudo apt update
sudo apt install python3-pip python3-venv nginx -y

# Cloner le repo
git clone https://github.com/votre-repo/digitrans-crm.git
cd digitrans-crm/backend

# Installer et lancer
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Lancer avec Gunicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:8000
```

---

## Étape 4 : Déploiement Frontend

### 4.1 Configuration

Éditer `frontend/config.js` :
```javascript
const CONFIG = {
    API_URL: 'https://votre-api-gateway-url.amazonaws.com/prod',
    AZURE_CLIENT_ID: 'votre-client-id',
    AZURE_TENANT_ID: 'votre-tenant-id',
    AZURE_REDIRECT_URI: 'https://votre-cloudfront-url.cloudfront.net/callback'
};
```

### 4.2 Déploiement sur S3

```bash
cd frontend

# Uploader les fichiers
aws s3 sync . s3://digitrans-crm-frontend/ \
    --exclude "*.md" \
    --exclude ".git/*" \
    --region af-south-1

# Invalider le cache CloudFront
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
    --query 'DistributionList.Items[0].Id' --output text)

aws cloudfront create-invalidation \
    --distribution-id $DISTRIBUTION_ID \
    --paths "/*"
```

---

## Étape 5 : Tests de Validation

### 5.1 Test de la Base de Données
```bash
psql -h digitrans-crm-db.xxxxxx.af-south-1.rds.amazonaws.com \
     -U admin -d crm_db -c "SELECT version();"
```

### 5.2 Test de l'API
```bash
# Health check
curl https://votre-api-url.amazonaws.com/health

# Test authentification
curl -X POST https://votre-api-url.amazonaws.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"token": "votre-token-azure-ad"}'
```

### 5.3 Test du Frontend
Ouvrir dans le navigateur : `https://votre-cloudfront-url.cloudfront.net`

---

## Étape 6 : Monitoring

### 6.1 Vérifier les Logs Azure Monitor
```bash
az monitor log-analytics query \
    --workspace $WORKSPACE_ID \
    --analytics-query "AppLogs | where TimeGenerated > ago(1h) | order by TimeGenerated desc" \
    --output table
```

### 6.2 Configurer les Alertes
```bash
# Créer une alerte pour erreurs API
az monitor metrics alert create \
    --name "API-High-Error-Rate" \
    --resource-group digitrans-crm-rg \
    --condition "avg Percentage CPU > 80" \
    --description "Alert when API error rate exceeds 5%"
```

---

## Dépannage

### Problème : Connexion à RDS refusée
**Solution** : Vérifier le Security Group et autoriser votre IP
```bash
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 5432 \
    --cidr votre-ip/32
```

### Problème : Erreur CORS sur l'API
**Solution** : Vérifier la configuration CORS dans `backend/app/main.py`

### Problème : Authentification Azure AD échoue
**Solution** : Vérifier les redirect URIs dans Azure AD App Registration

---

## Commandes Utiles

```bash
# Voir les logs Lambda
aws logs tail /aws/lambda/digitrans-crm-api --follow

# Lister les distributions CloudFront
aws cloudfront list-distributions

# Vérifier l'état RDS
aws rds describe-db-instances --db-instance-identifier digitrans-crm-db

# Tester la connexion PostgreSQL
psql $DATABASE_URL -c "SELECT NOW();"
```

---

## Sécurité Post-Déploiement

1. ✅ Changer tous les mots de passe par défaut
2. ✅ Activer MFA sur les comptes AWS et Azure
3. ✅ Configurer AWS CloudTrail pour l'audit
4. ✅ Activer le chiffrement RDS
5. ✅ Configurer les backups automatiques
6. ✅ Restreindre les Security Groups au minimum
7. ✅ Activer AWS GuardDuty
8. ✅ Configurer Azure Security Center

---

**Déploiement terminé ! 🚀**

URL Frontend : `https://votre-cloudfront-url.cloudfront.net`  
URL API : `https://votre-api-url.amazonaws.com`
