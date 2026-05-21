# SOLUTION: "The security token included in the request is invalid"

## Diagnostic Rapide

L'erreur signifie que GitHub Actions ne peut pas s'authentifier avec AWS. 

**Causes possibles:**
1. ❌ Secrets GitHub manquants ou mal configurés
2. ❌ Access Key invalide ou expirée
3. ❌ Utilisateur IAM supprimé ou désactivé
4. ❌ Permissions IAM insuffisantes

---

## SOLUTION 1: Vérifier les Secrets GitHub (2 min)

### Étape 1: Aller dans les Settings
```
https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions
```

### Étape 2: Vérifier que ces 3 secrets existent
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID` (optionnel mais recommandé)

### Étape 3: Si manquants, les créer
Cliquer sur **"New repository secret"** pour chaque secret.

---

## SOLUTION 2: Créer de Nouvelles Credentials AWS (5 min)

### Option A: Via AWS Console (Recommandé)

1. **Aller sur AWS Console IAM**
   ```
   https://console.aws.amazon.com/iam/
   ```

2. **Créer un nouvel utilisateur**
   - Cliquer sur "Users" → "Create user"
   - Nom: `github-actions-digitrans`
   - Cocher: "Provide user access to the AWS Management Console" → **NON**
   - Cliquer "Next"

3. **Attacher les permissions**
   - Sélectionner "Attach policies directly"
   - Cocher ces politiques:
     - ✅ `AmazonEC2ContainerRegistryFullAccess`
     - ✅ `AmazonEKSClusterPolicy`
     - ✅ `AmazonS3FullAccess`
     - ✅ `CloudFrontFullAccess`
   - Cliquer "Next" → "Create user"

4. **Créer Access Key**
   - Cliquer sur l'utilisateur créé
   - Onglet "Security credentials"
   - Cliquer "Create access key"
   - Sélectionner "Application running outside AWS"
   - Cliquer "Next" → "Create access key"
   - **⚠️ COPIER IMMÉDIATEMENT** les deux valeurs:
     - `Access key ID` (commence par AKIA...)
     - `Secret access key` (longue chaîne aléatoire)

### Option B: Via AWS CLI

```bash
# 1. Créer l'utilisateur
aws iam create-user --user-name github-actions-digitrans

# 2. Attacher les politiques
aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess

# 3. Créer les access keys
aws iam create-access-key --user-name github-actions-digitrans
```

**Résultat:**
```json
{
    "AccessKey": {
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "Status": "Active"
    }
}
```

---

## SOLUTION 3: Tester les Credentials Localement

### Utiliser le script de test

```bash
cd c:\Users\KENNETH\Desktop\Examen\scripts
test-aws-credentials-interactive.bat
```

Le script va:
1. ✅ Vérifier que AWS CLI est installé
2. ✅ Tester l'authentification avec `aws sts get-caller-identity`
3. ✅ Vérifier les permissions ECR, S3
4. ✅ Afficher les valeurs à copier dans GitHub

---

## SOLUTION 4: Ajouter les Secrets dans GitHub

### Méthode 1: Via l'interface web

1. Aller sur: `https://github.com/VOTRE_USER/VOTRE_REPO/settings/secrets/actions`
2. Cliquer "New repository secret"
3. Ajouter:

| Name | Value |
|------|-------|
| `AWS_ACCESS_KEY_ID` | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI/K7MDENG/bPxRfiCY...` |
| `AWS_ACCOUNT_ID` | `123456789012` |

### Méthode 2: Via GitHub CLI

```bash
# Installer GitHub CLI si nécessaire
# https://cli.github.com/

gh secret set AWS_ACCESS_KEY_ID -b "AKIAIOSFODNN7EXAMPLE"
gh secret set AWS_SECRET_ACCESS_KEY -b "wJalrXUtnFEMI/K7MDENG/bPxRfiCY..."
gh secret set AWS_ACCOUNT_ID -b "123456789012"
```

---

## SOLUTION 5: Vérifier la Région AWS

Le pipeline utilise `af-south-1` (Afrique du Sud). Vérifier que:

1. **La région est activée dans votre compte AWS**
   - Aller sur: https://console.aws.amazon.com/billing/home#/account
   - Section "AWS Regions"
   - Activer "Africa (Cape Town) af-south-1"

2. **L'utilisateur IAM a accès à cette région**
   - Par défaut, les nouvelles régions sont désactivées
   - Il faut les activer manuellement

---

## SOLUTION 6: Politique IAM Minimale (Sécurité Renforcée)

Si vous voulez limiter les permissions, créer une politique personnalisée:

```json
{
  "Version": "2012-10-17",
  "Statement": [
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
    },
    {
      "Sid": "EKSAccess",
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    },
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
        "arn:aws:s3:::digitrans-crm-frontend/*",
        "arn:aws:s3:::digitrans-crm-frontend"
      ]
    },
    {
      "Sid": "CloudFrontAccess",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    },
    {
      "Sid": "STSAccess",
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

Sauvegarder comme `github-actions-policy.json` et attacher:

```bash
aws iam put-user-policy \
  --user-name github-actions-digitrans \
  --policy-name GitHubActionsPolicy \
  --policy-document file://github-actions-policy.json
```

---

## Vérification Finale

Après avoir configuré les secrets, tester le pipeline:

```bash
# 1. Faire un petit changement
echo "# Test" >> README.md

# 2. Commit et push
git add README.md
git commit -m "test: verify AWS credentials"
git push origin main

# 3. Vérifier les logs GitHub Actions
# https://github.com/VOTRE_USER/VOTRE_REPO/actions
```

---

## Checklist de Résolution

- [ ] Secrets GitHub créés (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- [ ] Utilisateur IAM créé avec les bonnes permissions
- [ ] Access Keys générées et copiées
- [ ] Credentials testées localement avec le script
- [ ] Région `af-south-1` activée dans le compte AWS
- [ ] Pipeline relancé avec un nouveau commit
- [ ] Logs GitHub Actions vérifiés

---

## Support

Si le problème persiste:

1. **Vérifier les logs détaillés** dans GitHub Actions
2. **Tester localement** avec le script `test-aws-credentials-interactive.bat`
3. **Vérifier l'Account ID** avec `aws sts get-caller-identity`
4. **Régénérer les Access Keys** si nécessaire

**Temps de résolution estimé:** 5-10 minutes
