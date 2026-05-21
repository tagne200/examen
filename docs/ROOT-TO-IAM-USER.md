# CRÉER UTILISATEUR IAM DEPUIS COMPTE ROOT

## Problème Identifié

Vous utilisez les **credentials du compte ROOT** dans GitHub Actions.

**❌ PROBLÈME:** Les credentials root ne fonctionnent PAS avec GitHub Actions car:
- AWS bloque l'utilisation des credentials root pour les API programmatiques
- C'est une mauvaise pratique de sécurité
- Les credentials root ont trop de permissions

**✅ SOLUTION:** Créer un utilisateur IAM dédié pour GitHub Actions

---

## ÉTAPES DÉTAILLÉES (10 minutes)

### Étape 1: Se Connecter avec le Compte Root

```
https://console.aws.amazon.com/
```

- Utiliser votre **email root** et **mot de passe root**
- (Pas les Access Keys, juste l'email/password pour la console)

### Étape 2: Aller dans IAM

Une fois connecté:
1. Dans la barre de recherche AWS (en haut), taper: **IAM**
2. Cliquer sur **IAM** (Identity and Access Management)
3. Ou aller directement sur: https://console.aws.amazon.com/iam/

### Étape 3: Créer un Utilisateur IAM

1. Dans le menu de gauche, cliquer sur **"Users"**
2. Cliquer sur le bouton orange **"Create user"**
3. Remplir le formulaire:

```
User name: github-actions-digitrans

☐ Provide user access to the AWS Management Console
   (DÉCOCHER cette case - on ne veut PAS d'accès console)
```

4. Cliquer **"Next"**

### Étape 4: Attacher les Permissions

1. Sélectionner **"Attach policies directly"**

2. Dans la barre de recherche, chercher et **COCHER** ces 4 politiques:

```
☑ AmazonEC2ContainerRegistryFullAccess
☑ AmazonS3FullAccess  
☑ CloudFrontFullAccess
☑ IAMReadOnlyAccess (pour terraform)
```

**Comment les trouver:**
- Taper "ECR" dans la recherche → cocher `AmazonEC2ContainerRegistryFullAccess`
- Taper "S3" dans la recherche → cocher `AmazonS3FullAccess`
- Taper "CloudFront" dans la recherche → cocher `CloudFrontFullAccess`
- Taper "IAM" dans la recherche → cocher `IAMReadOnlyAccess`

3. Cliquer **"Next"**

4. Vérifier le résumé et cliquer **"Create user"**

### Étape 5: Créer les Access Keys

1. Dans la liste des utilisateurs, **cliquer sur** `github-actions-digitrans`

2. Cliquer sur l'onglet **"Security credentials"**

3. Descendre jusqu'à la section **"Access keys"**

4. Cliquer sur **"Create access key"**

5. Sélectionner le cas d'usage:
```
☑ Application running outside AWS
```

6. Cliquer **"Next"**

7. (Optionnel) Description tag:
```
Description: GitHub Actions CI/CD Pipeline
```

8. Cliquer **"Create access key"**

### Étape 6: COPIER LES CREDENTIALS ⚠️

Vous verrez un écran avec:

```
✅ Access key created

Access key: AKIAXXXXXXXXXXXXXXXXX
Secret access key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

⚠️ This is the only time you can view or download the secret access key.
```

**ACTIONS IMPORTANTES:**

1. **Copier l'Access Key** dans un fichier texte temporaire
2. **Copier la Secret Access Key** dans le même fichier
3. **Cliquer sur "Download .csv file"** (backup de sécurité)
4. **NE PAS FERMER** cette page avant d'avoir tout copié

**Exemple de ce que vous devez copier:**
```
Access Key ID: AKIAI44QH8DHBEXAMPLE
Secret Access Key: je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

---

## TESTER LES NOUVELLES CREDENTIALS

### Test 1: Localement

```bash
cd c:\Users\KENNETH\Desktop\Examen\scripts
test-aws-credentials-interactive.bat
```

**Entrer:**
- AWS_ACCESS_KEY_ID: `AKIAI44QH8DHBEXAMPLE` (votre nouvelle clé)
- AWS_SECRET_ACCESS_KEY: `je7MtGbClwBF/2Zp9Utk...` (votre nouveau secret)
- AWS_REGION: `af-south-1`

**Résultat attendu:**
```
[TEST 1] Verification identite...
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/github-actions-digitrans"
}
[OK] Credentials valides ✅
```

### Test 2: Vérifier l'Account ID

```bash
aws sts get-caller-identity --query Account --output text
```

Copier ce numéro (12 chiffres), vous en aurez besoin pour GitHub.

---

## METTRE À JOUR GITHUB SECRETS

### Étape 1: Aller dans GitHub Settings

```
https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions
```

### Étape 2: Supprimer les Anciens Secrets Root

Pour chaque secret existant:
1. Cliquer sur le secret
2. Cliquer sur **"Remove"**
3. Confirmer

Supprimer:
- `AWS_ACCESS_KEY_ID` (ancien root)
- `AWS_SECRET_ACCESS_KEY` (ancien root)
- `AWS_ACCOUNT_ID` (si existe)

### Étape 3: Créer les Nouveaux Secrets IAM

Cliquer **"New repository secret"** 3 fois:

**Secret 1:**
```
Name: AWS_ACCESS_KEY_ID
Value: AKIAI44QH8DHBEXAMPLE (votre nouvelle Access Key IAM)
```

**Secret 2:**
```
Name: AWS_SECRET_ACCESS_KEY
Value: je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY (votre nouveau Secret IAM)
```

**Secret 3:**
```
Name: AWS_ACCOUNT_ID
Value: 123456789012 (votre Account ID - 12 chiffres)
```

### Étape 4: Ajouter les Secrets Optionnels (pour plus tard)

**Secret 4:**
```
Name: S3_BUCKET_NAME
Value: digitrans-crm-frontend-prod
```

**Secret 5:**
```
Name: CLOUDFRONT_DISTRIBUTION_ID
Value: E1234EXAMPLE (à créer plus tard)
```

---

## VÉRIFIER LE PIPELINE

### Étape 1: Faire un Commit de Test

```bash
cd c:\Users\KENNETH\Desktop\Examen

# Petit changement
echo # Test IAM credentials >> README.md

# Commit
git add README.md
git commit -m "test: verify IAM credentials in GitHub Actions"

# Push
git push origin main
```

### Étape 2: Vérifier les Logs GitHub Actions

```
https://github.com/VOTRE_USERNAME/VOTRE_REPO/actions
```

**Résultat attendu dans le job "terraform":**
```
Run aws-actions/configure-aws-credentials@v4
✅ Credentials configured successfully
```

---

## DIFFÉRENCE ROOT vs IAM USER

| Aspect | Compte ROOT | Utilisateur IAM |
|--------|-------------|-----------------|
| **Email** | Votre email principal | Nom d'utilisateur |
| **Accès Console** | ✅ Oui (email + password) | ❌ Non (sauf si activé) |
| **Access Keys** | ❌ Ne marche pas avec GitHub Actions | ✅ Fonctionne |
| **Permissions** | Toutes (dangereux) | Limitées (sécurisé) |
| **Utilisation** | Administration compte | Automatisation CI/CD |
| **Bonnes pratiques** | Ne jamais utiliser pour API | ✅ Recommandé |

---

## SÉCURITÉ DU COMPTE ROOT

**⚠️ IMPORTANT:** Maintenant que vous avez créé un utilisateur IAM:

1. **NE PLUS UTILISER** les credentials root
2. **Activer MFA** sur le compte root:
   - IAM → Dashboard → "Add MFA for root user"
3. **Supprimer les Access Keys root** (si elles existent):
   - Compte root → Security credentials → Access keys → Delete

---

## TROUBLESHOOTING

### Si l'erreur persiste après avoir créé l'utilisateur IAM:

**1. Vérifier que vous avez bien utilisé les NOUVELLES credentials IAM:**
```bash
# Tester localement
aws sts get-caller-identity
```

Doit afficher:
```json
{
    "Arn": "arn:aws:iam::123456789012:user/github-actions-digitrans"
                                          ^^^^^ doit dire "user", pas "root"
}
```

**2. Vérifier les permissions de l'utilisateur:**
```bash
aws iam list-attached-user-policies --user-name github-actions-digitrans
```

**3. Vérifier que les secrets GitHub sont bien mis à jour:**
- Aller dans Settings → Secrets → Actions
- Vérifier que les secrets ont été modifiés récemment (date)

**4. Vérifier que la région af-south-1 est activée:**
- https://console.aws.amazon.com/billing/home#/account
- AWS Regions → Activer "Africa (Cape Town)"

---

## CHECKLIST COMPLÈTE

- [ ] Connecté à AWS Console avec compte root
- [ ] Utilisateur IAM créé: `github-actions-digitrans`
- [ ] 4 permissions attachées (ECR, S3, CloudFront, IAM)
- [ ] Access Keys créées pour l'utilisateur IAM
- [ ] Credentials testées localement (✅ succès)
- [ ] Anciens secrets root supprimés de GitHub
- [ ] Nouveaux secrets IAM ajoutés dans GitHub
- [ ] Commit de test poussé
- [ ] Pipeline GitHub Actions vérifié (✅ succès)

---

## RÉSUMÉ

**Problème:** Credentials root ne fonctionnent pas avec GitHub Actions
**Solution:** Créer un utilisateur IAM dédié avec Access Keys
**Temps:** 10 minutes
**Coût:** Gratuit
**Sécurité:** ✅ Meilleure pratique AWS

**Prochaine étape:** Tester le pipeline avec les nouvelles credentials IAM
