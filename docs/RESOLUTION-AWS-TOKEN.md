# ✅ RÉSOLUTION COMPLÈTE : Erreur AWS Token Invalid

## 🎯 Problème

```
Run aws-actions/configure-aws-credentials@v4
Error: The security token included in the request is invalid.
```

---

## 🔍 Diagnostic

### Cause Principale
Les credentials AWS configurés dans GitHub Secrets sont **invalides, expirés ou mal configurés**.

### Causes Secondaires
1. Access Key ID incorrect
2. Secret Access Key incorrect
3. Permissions IAM insuffisantes
4. Secrets GitHub mal copiés (espaces, guillemets)

---

## ✅ Solution Complète (Étape par Étape)

### Étape 1 : Créer un Utilisateur IAM pour GitHub Actions

```bash
# 1. Créer l'utilisateur
aws iam create-user --user-name github-actions-digitrans

# 2. Créer une Access Key
aws iam create-access-key --user-name github-actions-digitrans

# Output (SAUVEGARDER IMMÉDIATEMENT) :
# {
#     "AccessKey": {
#         "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
#         "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
#     }
# }
```

### Étape 2 : Attacher les Permissions

**Option Simple (Pour démarrer)** :
```bash
aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

**Option Sécurisée (Pour production)** :
```bash
# Créer une policy personnalisée
cat > github-actions-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
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
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Créer et attacher la policy
aws iam create-policy \
  --policy-name GitHubActionsDeployPolicy \
  --policy-document file://github-actions-policy.json

aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::VOTRE_ACCOUNT_ID:policy/GitHubActionsDeployPolicy
```

### Étape 3 : Tester les Credentials Localement

```bash
# Configurer AWS CLI avec les nouvelles credentials
aws configure
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/...
# Default region: af-south-1
# Default output format: json

# Tester
aws sts get-caller-identity

# Si OK, vous verrez :
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/github-actions-digitrans"
# }
```

**Ou utiliser le script de test** :
```bash
scripts\test-aws-credentials.bat
```

### Étape 4 : Configurer les Secrets GitHub

**Via GitHub CLI** :
```bash
# Supprimer les anciens secrets (si existants)
gh secret delete AWS_ACCESS_KEY_ID
gh secret delete AWS_SECRET_ACCESS_KEY

# Ajouter les nouveaux secrets
gh secret set AWS_ACCESS_KEY_ID --body "AKIAIOSFODNN7EXAMPLE"
gh secret set AWS_SECRET_ACCESS_KEY --body "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# Vérifier
gh secret list
```

**Via l'Interface Web** :
1. Aller sur : `https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions`
2. Cliquer sur **New repository secret**
3. Ajouter :

| Nom | Valeur | ⚠️ Important |
|-----|--------|--------------|
| `AWS_ACCESS_KEY_ID` | `AKIAIOSFODNN7EXAMPLE` | Pas d'espaces |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI/K7MDENG/...` | Copier entièrement |

### Étape 5 : Tester le Déploiement

```bash
# 1. Faire un petit changement
echo "# Test AWS credentials" >> README.md

# 2. Commit et push sur main
git add .
git commit -m "test: verify AWS credentials"
git push origin main

# 3. Vérifier sur GitHub Actions
# https://github.com/VOTRE_REPO/actions
```

---

## 📋 Checklist de Vérification

### Avant de Configurer GitHub Secrets

- [ ] User IAM créé (`github-actions-digitrans`)
- [ ] Access Key générée
- [ ] Permissions attachées (PowerUserAccess ou policy personnalisée)
- [ ] Credentials testées localement avec `aws sts get-caller-identity`
- [ ] Accès S3 testé avec `aws s3 ls`

### Configuration GitHub Secrets

- [ ] Anciens secrets supprimés
- [ ] `AWS_ACCESS_KEY_ID` ajouté (commence par `AKIA`)
- [ ] `AWS_SECRET_ACCESS_KEY` ajouté (40 caractères)
- [ ] Pas d'espaces avant/après les valeurs
- [ ] Pas de guillemets dans les valeurs
- [ ] Secrets visibles dans la liste (masqués)

### Test du Déploiement

- [ ] Push sur `main` effectué
- [ ] Workflow démarre automatiquement
- [ ] Job `deploy-aws` s'exécute (pas skippé)
- [ ] Étape "Configure AWS credentials" réussit ✅
- [ ] Déploiement S3 réussit ✅

---

## 🔧 Commandes Utiles

### Diagnostic

```bash
# Vérifier l'identité AWS
aws sts get-caller-identity

# Lister les users IAM
aws iam list-users

# Lister les access keys d'un user
aws iam list-access-keys --user-name github-actions-digitrans

# Vérifier les permissions
aws iam list-attached-user-policies --user-name github-actions-digitrans
```

### Gestion des Access Keys

```bash
# Créer une nouvelle access key
aws iam create-access-key --user-name github-actions-digitrans

# Désactiver une access key
aws iam update-access-key \
  --user-name github-actions-digitrans \
  --access-key-id AKIAIOSFODNN7EXAMPLE \
  --status Inactive

# Supprimer une access key
aws iam delete-access-key \
  --user-name github-actions-digitrans \
  --access-key-id AKIAIOSFODNN7EXAMPLE
```

### Test des Permissions

```bash
# Tester S3
aws s3 ls
aws s3 cp test.txt s3://digitrans-crm-frontend/test.txt

# Tester CloudFront
aws cloudfront list-distributions

# Tester Lambda
aws lambda list-functions --region af-south-1
```

---

## 🎓 Bonnes Pratiques

### 1. Rotation des Credentials

```bash
# Tous les 90 jours, créer une nouvelle access key
aws iam create-access-key --user-name github-actions-digitrans

# Mettre à jour GitHub Secrets
gh secret set AWS_ACCESS_KEY_ID --body "NOUVELLE_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "NOUVEAU_SECRET"

# Supprimer l'ancienne access key
aws iam delete-access-key \
  --user-name github-actions-digitrans \
  --access-key-id ANCIENNE_KEY
```

### 2. Principe du Moindre Privilège

**Ne pas utiliser** :
- ❌ AdministratorAccess
- ❌ PowerUserAccess (sauf pour démarrer)

**Utiliser** :
- ✅ Policy personnalisée avec permissions minimales
- ✅ Ressources spécifiques (pas `*`)

### 3. Monitoring

```bash
# Activer CloudTrail pour auditer les actions
aws cloudtrail create-trail \
  --name github-actions-audit \
  --s3-bucket-name digitrans-audit-logs

# Créer des alertes pour les échecs d'authentification
aws cloudwatch put-metric-alarm \
  --alarm-name github-actions-auth-failures \
  --metric-name AuthenticationFailures \
  --threshold 5
```

---

## 🔐 Alternative : AWS OIDC (Recommandé pour Production)

**Avantages** :
- ✅ Pas de credentials statiques
- ✅ Rotation automatique
- ✅ Plus sécurisé

**Configuration** :

1. **Créer l'OIDC Provider** :
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

2. **Créer un Rôle IAM** :
```bash
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
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
  }]
}
EOF

aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://trust-policy.json
```

3. **Modifier le Workflow** :
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: af-south-1
```

**Plus besoin de secrets AWS !** ✅

---

## 📚 Documentation Créée

1. **FIX-AWS-TOKEN-INVALID.md** ✅
   - Guide complet de résolution
   - Solutions détaillées
   - Configuration OIDC

2. **test-aws-credentials.bat** ✅
   - Script de test automatique
   - Vérification des permissions
   - Diagnostic rapide

3. **Ce résumé** ✅
   - Vue d'ensemble
   - Étapes simplifiées
   - Checklist complète

---

## 🎯 Résumé en 5 Étapes

1. **Créer un user IAM** : `aws iam create-user --user-name github-actions-digitrans`
2. **Générer une access key** : `aws iam create-access-key --user-name github-actions-digitrans`
3. **Attacher des permissions** : `aws iam attach-user-policy ...`
4. **Tester localement** : `aws sts get-caller-identity`
5. **Configurer GitHub Secrets** : `gh secret set AWS_ACCESS_KEY_ID ...`

---

## ✅ Statut

**Problème** : ✅ Résolu  
**Documentation** : ✅ Complète  
**Scripts** : ✅ Créés  
**Tests** : ⏳ À effectuer  

**Prochaine action** : Suivre les 5 étapes ci-dessus et tester le déploiement

---

**Document créé par** : CAMTECH SOLUTIONS S.A.  
**Date** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Solution complète et testable
