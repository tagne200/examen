# 🔐 Résolution : "The security token included in the request is invalid"

## ❌ Erreur Rencontrée

```
Run aws-actions/configure-aws-credentials@v4
Error: The security token included in the request is invalid.
```

---

## 🔍 Causes Possibles

### 1. Credentials AWS Invalides ou Expirés ⚠️

**Symptômes** :
- Token de sécurité invalide
- Access Key ID incorrect
- Secret Access Key incorrect

### 2. Secrets GitHub Mal Configurés ⚠️

**Symptômes** :
- Secrets vides
- Secrets avec espaces ou caractères spéciaux
- Secrets copiés incorrectement

### 3. Permissions IAM Insuffisantes ⚠️

**Symptômes** :
- User IAM n'a pas les permissions nécessaires
- Policy trop restrictive

### 4. Région AWS Incorrecte ⚠️

**Symptômes** :
- Région non disponible
- Services non disponibles dans la région

---

## ✅ Solutions

### Solution 1 : Vérifier et Régénérer les Credentials AWS

#### Étape 1 : Vérifier les Credentials Localement

```bash
# Tester les credentials localement
aws sts get-caller-identity

# Si ça fonctionne, vous verrez :
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/github-actions"
# }

# Si erreur, vos credentials sont invalides
```

#### Étape 2 : Créer un Nouvel Utilisateur IAM

```bash
# 1. Créer un utilisateur pour GitHub Actions
aws iam create-user --user-name github-actions-digitrans

# 2. Créer une Access Key
aws iam create-access-key --user-name github-actions-digitrans

# Output (SAUVEGARDER IMMÉDIATEMENT) :
# {
#     "AccessKey": {
#         "UserName": "github-actions-digitrans",
#         "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
#         "Status": "Active",
#         "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
#         "CreateDate": "2025-01-20T10:00:00Z"
#     }
# }
```

#### Étape 3 : Attacher les Permissions Nécessaires

**Option A : Policy Managée (Recommandé pour démarrer)**

```bash
# Attacher une policy managée
aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

**Option B : Policy Personnalisée (Recommandé pour production)**

```bash
# Créer une policy personnalisée
cat > github-actions-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3Access",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::digitrans-crm-frontend",
        "arn:aws:s3:::digitrans-crm-frontend/*"
      ]
    },
    {
      "Sid": "CloudFrontAccess",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Resource": "*"
    },
    {
      "Sid": "LambdaAccess",
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:PublishVersion"
      ],
      "Resource": "arn:aws:lambda:af-south-1:*:function:digitrans-crm-api"
    },
    {
      "Sid": "ECRAccess",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Créer la policy
aws iam create-policy \
  --policy-name GitHubActionsDeployPolicy \
  --policy-document file://github-actions-policy.json

# Attacher la policy
aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::123456789012:policy/GitHubActionsDeployPolicy
```

---

### Solution 2 : Configurer Correctement les Secrets GitHub

#### Étape 1 : Supprimer les Anciens Secrets

```bash
# Via GitHub CLI
gh secret delete AWS_ACCESS_KEY_ID
gh secret delete AWS_SECRET_ACCESS_KEY

# Ou via l'interface web
# Settings → Secrets and variables → Actions → Delete
```

#### Étape 2 : Ajouter les Nouveaux Secrets

**Via GitHub CLI** :

```bash
# Ajouter AWS_ACCESS_KEY_ID
gh secret set AWS_ACCESS_KEY_ID --body "AKIAIOSFODNN7EXAMPLE"

# Ajouter AWS_SECRET_ACCESS_KEY
gh secret set AWS_SECRET_ACCESS_KEY --body "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# Vérifier
gh secret list
```

**Via l'Interface Web** :

1. Aller sur : `https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions`
2. Cliquer sur **New repository secret**
3. Ajouter chaque secret :

| Nom | Valeur | ⚠️ Important |
|-----|--------|--------------|
| `AWS_ACCESS_KEY_ID` | `AKIAIOSFODNN7EXAMPLE` | Pas d'espaces avant/après |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI/K7MDENG/...` | Copier entièrement |
| `AWS_REGION` | `af-south-1` | Optionnel |

**⚠️ Attention** :
- Pas d'espaces avant ou après
- Pas de guillemets
- Copier-coller directement depuis AWS CLI output

---

### Solution 3 : Utiliser AWS OIDC (Recommandé pour Production)

**Avantages** :
- ✅ Pas de credentials statiques
- ✅ Plus sécurisé
- ✅ Rotation automatique

#### Étape 1 : Créer un Identity Provider OIDC

```bash
# Créer l'OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### Étape 2 : Créer un Rôle IAM

```bash
# Créer le trust policy
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:VOTRE_USERNAME/VOTRE_REPO:*"
        }
      }
    }
  ]
}
EOF

# Créer le rôle
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://trust-policy.json

# Attacher les permissions
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::123456789012:policy/GitHubActionsDeployPolicy
```

#### Étape 3 : Modifier le Workflow

```yaml
deploy-aws:
  name: Deploy to AWS
  runs-on: ubuntu-latest
  permissions:
    id-token: write  # ← Requis pour OIDC
    contents: read
  
  steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Configure AWS credentials (OIDC)
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
        aws-region: af-south-1
    
    - name: Deploy
      run: |
        aws s3 sync frontend/ s3://digitrans-crm-frontend/
```

**Avantages** :
- ✅ Pas besoin de `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY`
- ✅ Plus sécurisé
- ✅ Recommandé par AWS

---

### Solution 4 : Vérifier la Région AWS

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: af-south-1  # ← Vérifier que cette région existe
```

**Régions AWS en Afrique** :
- ✅ `af-south-1` (Cape Town) - Disponible
- ❌ `af-north-1` - N'existe pas

---

## 🧪 Tests de Validation

### Test 1 : Vérifier les Credentials Localement

```bash
# Configurer les credentials localement
aws configure
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/...
# Default region: af-south-1
# Default output format: json

# Tester
aws sts get-caller-identity

# Si OK, vous verrez votre User ID et Account ID
```

### Test 2 : Tester les Permissions S3

```bash
# Lister les buckets
aws s3 ls

# Uploader un fichier test
echo "test" > test.txt
aws s3 cp test.txt s3://digitrans-crm-frontend/test.txt

# Si OK, les permissions sont correctes
```

### Test 3 : Tester dans GitHub Actions

**Créer un workflow de test** :

```yaml
name: Test AWS Credentials

on:
  workflow_dispatch:  # Déclenchement manuel

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: af-south-1
      
      - name: Test credentials
        run: |
          echo "Testing AWS credentials..."
          aws sts get-caller-identity
          aws s3 ls
          echo "✅ Credentials are valid!"
```

**Exécuter** :
1. Actions → Test AWS Credentials → Run workflow
2. Vérifier les logs

---

## 📋 Checklist de Dépannage

### Étape 1 : Vérifier les Credentials

- [ ] Credentials testés localement avec `aws sts get-caller-identity`
- [ ] Access Key ID commence par `AKIA`
- [ ] Secret Access Key a 40 caractères
- [ ] Pas d'espaces avant/après

### Étape 2 : Vérifier les Secrets GitHub

- [ ] Secrets ajoutés dans Settings → Secrets
- [ ] Noms exacts : `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- [ ] Pas de guillemets dans les valeurs
- [ ] Secrets visibles dans la liste (masqués)

### Étape 3 : Vérifier les Permissions IAM

- [ ] User IAM existe
- [ ] Policy attachée au user
- [ ] Permissions S3, CloudFront, Lambda (selon besoins)
- [ ] Région `af-south-1` accessible

### Étape 4 : Tester

- [ ] Test local réussi
- [ ] Test GitHub Actions réussi
- [ ] Déploiement réussi

---

## 🔧 Workflow Corrigé

```yaml
deploy-aws:
  name: Deploy to AWS
  runs-on: ubuntu-latest
  needs: [test-backend, lint-and-security, build-docker]
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  
  steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: af-south-1
    
    - name: Verify AWS credentials
      run: |
        echo "Verifying AWS credentials..."
        aws sts get-caller-identity
        echo "✅ Credentials verified!"
    
    - name: Deploy Frontend to S3
      run: |
        cd frontend
        aws s3 sync . s3://${{ secrets.S3_BUCKET_NAME }}/ \
          --exclude "*.md" \
          --exclude ".git/*" \
          --delete
    
    - name: Invalidate CloudFront cache
      run: |
        aws cloudfront create-invalidation \
          --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
          --paths "/*"
```

---

## 📊 Comparaison des Méthodes

| Méthode | Sécurité | Complexité | Recommandé |
|---------|----------|------------|------------|
| **Access Keys** | ⚠️ Moyen | ✅ Simple | Dev/Test |
| **OIDC** | ✅ Élevé | ⚠️ Moyen | Production |
| **IAM Roles** | ✅ Élevé | ⚠️ Complexe | Enterprise |

---

## 🎯 Solution Recommandée (Étape par Étape)

### Pour Démarrer Rapidement (Access Keys)

```bash
# 1. Créer un user IAM
aws iam create-user --user-name github-actions-digitrans

# 2. Créer une access key
aws iam create-access-key --user-name github-actions-digitrans
# SAUVEGARDER : AccessKeyId et SecretAccessKey

# 3. Attacher une policy
aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# 4. Ajouter dans GitHub Secrets
gh secret set AWS_ACCESS_KEY_ID --body "VOTRE_ACCESS_KEY_ID"
gh secret set AWS_SECRET_ACCESS_KEY --body "VOTRE_SECRET_ACCESS_KEY"

# 5. Tester
git push origin main
```

### Pour Production (OIDC)

Suivre la **Solution 3** ci-dessus.

---

## 🔗 Ressources

- **AWS IAM Best Practices** : https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
- **GitHub Actions AWS** : https://github.com/aws-actions/configure-aws-credentials
- **AWS OIDC** : https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

---

## ✅ Résumé

**Erreur** : "The security token included in the request is invalid"

**Causes** :
1. Credentials AWS invalides
2. Secrets GitHub mal configurés
3. Permissions IAM insuffisantes

**Solution Rapide** :
1. Créer un nouveau user IAM
2. Générer une nouvelle access key
3. Ajouter dans GitHub Secrets
4. Tester

**Solution Production** :
- Utiliser AWS OIDC (pas de credentials statiques)

---

**Document créé par** : CAMTECH SOLUTIONS S.A.  
**Date** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Solution complète
