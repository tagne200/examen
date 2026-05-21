# CONFIGURATION SECRETS GITHUB - DÉMARRAGE RAPIDE

## Secrets OBLIGATOIRES (Pour commencer)

Allez sur: `https://github.com/tagne200/examen/settings/secrets/actions`

### 1. AWS_ACCESS_KEY_ID
```
Name: AWS_ACCESS_KEY_ID
Value: AKIAXXXXXXXXXXXXXXXXX (votre nouvelle Access Key IAM)
```

### 2. AWS_SECRET_ACCESS_KEY
```
Name: AWS_SECRET_ACCESS_KEY
Value: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (votre nouveau Secret IAM)
```

### 3. AWS_ACCOUNT_ID
```
Name: AWS_ACCOUNT_ID
Value: 123456789012 (votre Account ID - 12 chiffres)
```

**Comment obtenir l'Account ID:**
```bash
aws sts get-caller-identity --query Account --output text
```

### 4. S3_BUCKET_NAME
```
Name: S3_BUCKET_NAME
Value: digitrans-crm-frontend-prod
```

---

## Secrets OPTIONNELS (Pour plus tard)

### 5. CLOUDFRONT_DISTRIBUTION_ID (PAS NÉCESSAIRE MAINTENANT)

**CloudFront est désactivé temporairement dans le pipeline.**

Vous pouvez le créer plus tard avec:
```bash
cd c:\Users\KENNETH\Desktop\Examen\scripts
create-cloudfront.bat
```

Ou via AWS Console:
```
https://console.aws.amazon.com/cloudfront/
```

---

## RÉSUMÉ: 4 Secrets Minimum

Pour déployer maintenant, vous avez besoin de:

1. ✅ `AWS_ACCESS_KEY_ID`
2. ✅ `AWS_SECRET_ACCESS_KEY`
3. ✅ `AWS_ACCOUNT_ID`
4. ✅ `S3_BUCKET_NAME`

**CloudFront peut attendre!**

---

## ÉTAPES SUIVANTES

### 1. Créer l'utilisateur IAM

```
https://console.aws.amazon.com/iam/home#/users
```

- User: `github-actions-digitrans`
- Permissions: ECR, S3, CloudFront, VPC, RDS, IAM
- Créer Access Keys
- **COPIER** les credentials

### 2. Tester localement

```bash
aws configure
# Entrer les nouvelles credentials

aws sts get-caller-identity
# Doit afficher votre Account ID
```

### 3. Créer le bucket S3

```bash
aws s3 mb s3://digitrans-crm-frontend-prod --region af-south-1

aws s3 website s3://digitrans-crm-frontend-prod --index-document index.html
```

### 4. Ajouter les 4 secrets dans GitHub

```
https://github.com/tagne200/examen/settings/secrets/actions
```

Cliquer "New repository secret" 4 fois.

### 5. Commit et push

```bash
cd c:\Users\KENNETH\Desktop\Examen

git add .
git commit -m "ci: configure pipeline without CloudFront"
git push origin main
```

### 6. Vérifier le pipeline

```
https://github.com/tagne200/examen/actions
```

Le pipeline doit:
- ✅ Exécuter les tests
- ✅ Terraform (peut échouer si pas d'infra)
- ✅ Build Docker
- ✅ Deploy S3

---

## PLUS TARD: Ajouter CloudFront

Quand vous serez prêt:

1. **Créer la distribution:**
   ```bash
   cd scripts
   create-cloudfront.bat
   ```

2. **Copier le Distribution ID**

3. **Ajouter dans GitHub Secrets:**
   ```
   Name: CLOUDFRONT_DISTRIBUTION_ID
   Value: E1234EXAMPLE
   ```

4. **Réactiver dans le pipeline:**
   Modifier `.github/workflows/ci-cd.yml`:
   ```yaml
   - name: Invalidate CloudFront cache
     if: false  # ← Changer en: if: true
   ```

5. **Commit et push**

---

## TROUBLESHOOTING

### Erreur: "Bucket already exists"
Le bucket existe déjà. Utilisez un autre nom:
```
digitrans-crm-frontend-prod-v2
```

### Erreur: "Access Denied"
Vérifiez les permissions IAM de l'utilisateur.

### Erreur: "Invalid credentials"
Retestez localement:
```bash
aws sts get-caller-identity
```

---

## COÛT

**Sans CloudFront:**
- S3: ~$0.12/mois (5GB)
- ECR: ~$1/mois (10 images)
- **Total: ~$1/mois**

**Avec CloudFront:**
- CloudFront: ~$1-5/mois (selon trafic)
- **Total: ~$2-6/mois**

---

## RÉSUMÉ

**Pour déployer MAINTENANT:**
1. Créer utilisateur IAM
2. Créer bucket S3
3. Ajouter 4 secrets GitHub
4. Push vers main

**CloudFront = OPTIONNEL pour l'instant!**
