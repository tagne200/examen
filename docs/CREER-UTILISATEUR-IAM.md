# CRÉER UN NOUVEL UTILISATEUR IAM AWS

## Problème Identifié
Les credentials actuelles sont **INVALIDES**:
- Access Key: `AKIA3A7OI7EFZMQTRDMA` ❌
- L'utilisateur IAM a été supprimé, désactivé, ou les keys sont incorrectes

## SOLUTION: Créer un Nouvel Utilisateur IAM

### Méthode 1: Via AWS Console (RECOMMANDÉ - 5 minutes)

#### Étape 1: Se connecter à AWS Console
```
https://console.aws.amazon.com/
```
- Utiliser votre compte root ou un compte admin

#### Étape 2: Aller dans IAM
```
https://console.aws.amazon.com/iam/home#/users
```
- Ou chercher "IAM" dans la barre de recherche AWS

#### Étape 3: Créer un Utilisateur
1. Cliquer sur **"Users"** dans le menu de gauche
2. Cliquer sur **"Create user"** (bouton orange)
3. **User name**: `github-actions-digitrans`
4. **DÉCOCHER** "Provide user access to the AWS Management Console"
5. Cliquer **"Next"**

#### Étape 4: Attacher les Permissions
1. Sélectionner **"Attach policies directly"**
2. Dans la barre de recherche, chercher et cocher:
   - ✅ `AmazonEC2ContainerRegistryFullAccess`
   - ✅ `AmazonS3FullAccess`
   - ✅ `CloudFrontFullAccess`
3. Cliquer **"Next"**
4. Cliquer **"Create user"**

#### Étape 5: Créer les Access Keys
1. Cliquer sur l'utilisateur **"github-actions-digitrans"** que vous venez de créer
2. Aller dans l'onglet **"Security credentials"**
3. Descendre jusqu'à **"Access keys"**
4. Cliquer **"Create access key"**
5. Sélectionner **"Application running outside AWS"**
6. Cliquer **"Next"**
7. (Optionnel) Description: `GitHub Actions CI/CD`
8. Cliquer **"Create access key"**

#### Étape 6: COPIER LES CREDENTIALS ⚠️
```
Access key ID: AKIAXXXXXXXXXXXXXXXXX
Secret access key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**⚠️ IMPORTANT:** 
- Copier ces valeurs IMMÉDIATEMENT
- Vous ne pourrez JAMAIS revoir la Secret Access Key
- Si vous la perdez, il faudra créer une nouvelle Access Key

#### Étape 7: Télécharger le fichier CSV (Recommandé)
- Cliquer **"Download .csv file"**
- Sauvegarder dans un endroit sécurisé

---

### Méthode 2: Via AWS CLI (Si vous avez un compte admin configuré)

```bash
# 1. Créer l'utilisateur
aws iam create-user --user-name github-actions-digitrans

# 2. Attacher les politiques
aws iam attach-user-policy \
  --user-name github-actions-digitrans \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

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
        "UserName": "github-actions-digitrans",
        "AccessKeyId": "AKIAIOSFODNN7EXAMPLE",
        "Status": "Active",
        "SecretAccessKey": "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "CreateDate": "2024-01-15T10:30:00Z"
    }
}
```

---

## TESTER LES NOUVELLES CREDENTIALS

### Option 1: Script Interactif
```bash
cd c:\Users\KENNETH\Desktop\Examen\scripts
test-aws-credentials-interactive.bat
```

Entrer les NOUVELLES credentials.

### Option 2: Commande Directe
```bash
# Configurer temporairement
set AWS_ACCESS_KEY_ID=VOTRE_NOUVELLE_ACCESS_KEY
set AWS_SECRET_ACCESS_KEY=VOTRE_NOUVELLE_SECRET_KEY
set AWS_DEFAULT_REGION=af-south-1

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

---

## AJOUTER DANS GITHUB SECRETS

### Étape 1: Aller dans les Settings GitHub
```
https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions
```

### Étape 2: Supprimer les Anciens Secrets (si existants)
- Cliquer sur chaque secret → "Remove"

### Étape 3: Créer les Nouveaux Secrets
Cliquer **"New repository secret"** 3 fois:

| Name | Value | Exemple |
|------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Votre nouvelle Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Votre nouvelle Secret Key | `wJalrXUtnFEMI/K7MDENG...` |
| `AWS_ACCOUNT_ID` | Votre Account ID (12 chiffres) | `123456789012` |

**Pour trouver votre Account ID:**
```bash
aws sts get-caller-identity --query Account --output text
```

---

## VÉRIFIER LE PIPELINE

### Étape 1: Faire un Commit de Test
```bash
cd c:\Users\KENNETH\Desktop\Examen

# Petit changement
echo # Test credentials >> README.md

# Commit et push
git add README.md
git commit -m "test: verify new AWS credentials"
git push origin main
```

### Étape 2: Vérifier les Logs
```
https://github.com/VOTRE_USERNAME/VOTRE_REPO/actions
```

Le job **"terraform"** devrait maintenant passer ✅

---

## TROUBLESHOOTING

### Si l'erreur persiste:

1. **Vérifier que la région af-south-1 est activée**
   - Aller sur: https://console.aws.amazon.com/billing/home#/account
   - Section "AWS Regions"
   - Activer "Africa (Cape Town) af-south-1"

2. **Vérifier les permissions de l'utilisateur**
   ```bash
   aws iam list-attached-user-policies --user-name github-actions-digitrans
   ```

3. **Vérifier que les Access Keys sont actives**
   ```bash
   aws iam list-access-keys --user-name github-actions-digitrans
   ```

4. **Créer une nouvelle Access Key si nécessaire**
   - Supprimer l'ancienne dans AWS Console
   - Créer une nouvelle
   - Mettre à jour GitHub Secrets

---

## SÉCURITÉ

### Bonnes Pratiques:
- ✅ Ne JAMAIS commiter les credentials dans Git
- ✅ Utiliser GitHub Secrets pour stocker les credentials
- ✅ Limiter les permissions IAM au strict nécessaire
- ✅ Rotation régulière des Access Keys (tous les 90 jours)
- ✅ Activer MFA sur le compte AWS root

### Permissions Minimales (Alternative):
Si vous voulez limiter les permissions, créer une politique personnalisée:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*",
        "s3:*",
        "cloudfront:CreateInvalidation",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## CHECKLIST

- [ ] Utilisateur IAM créé: `github-actions-digitrans`
- [ ] Permissions attachées (ECR, S3, CloudFront)
- [ ] Access Keys créées
- [ ] Credentials testées localement (✅ succès)
- [ ] GitHub Secrets mis à jour
- [ ] Pipeline relancé
- [ ] Logs vérifiés (✅ succès)

---

## RÉSUMÉ

**Problème:** Credentials AWS invalides
**Cause:** Utilisateur IAM supprimé ou Access Keys incorrectes
**Solution:** Créer un nouvel utilisateur IAM avec de nouvelles Access Keys
**Temps:** 5-10 minutes
**Coût:** Gratuit (IAM est gratuit)
