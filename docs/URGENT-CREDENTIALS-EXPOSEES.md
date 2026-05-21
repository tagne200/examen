# ⚠️ URGENT: CREDENTIALS EXPOSÉES SUR GITHUB

## 🚨 SITUATION CRITIQUE

Vos credentials AWS `AKIA3A7OI7EFZMQTRDMA` ont été **EXPOSÉES PUBLIQUEMENT** sur GitHub.

**Risques:**
- ❌ N'importe qui peut les voir dans l'historique Git
- ❌ Utilisation frauduleuse possible
- ❌ Coûts AWS non autorisés
- ❌ Accès à vos ressources AWS

---

## ✅ ACTION IMMÉDIATE (5 MINUTES)

### Étape 1: Révoquer les Credentials Exposées

**Option A: Via AWS Console (RAPIDE)**

1. **Se connecter:**
   ```
   https://console.aws.amazon.com/iam/home#/security_credentials
   ```

2. **Aller dans "Access keys"**

3. **Trouver la clé:** `AKIA3A7OI7EFZMQTRDMA`

4. **Cliquer "Actions" → "Delete"**

5. **Confirmer la suppression**

**Option B: Via AWS CLI**

```bash
# Lister les access keys
aws iam list-access-keys --user-name VOTRE_UTILISATEUR

# Supprimer la clé exposée
aws iam delete-access-key --access-key-id AKIA3A7OI7EFZMQTRDMA --user-name VOTRE_UTILISATEUR
```

---

### Étape 2: Créer de Nouvelles Credentials

**Via AWS Console:**

1. **Aller sur:**
   ```
   https://console.aws.amazon.com/iam/home#/users
   ```

2. **Créer un nouvel utilisateur:** `github-actions-digitrans-v2`

3. **Attacher les permissions:**
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`
   - `IAMReadOnlyAccess`

4. **Créer Access Keys**

5. **COPIER** les nouvelles credentials

6. **NE PAS** les mettre dans des fichiers de documentation!

---

### Étape 3: Mettre à Jour GitHub Secrets

```
https://github.com/tagne200/examen/settings/secrets/actions
```

1. **Supprimer** les anciens secrets

2. **Créer** 3 nouveaux secrets avec les NOUVELLES credentials:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`

---

### Étape 4: Nettoyer l'Historique Git (Optionnel mais Recommandé)

**⚠️ ATTENTION:** Ceci va réécrire l'historique Git!

```bash
cd c:\Users\KENNETH\Desktop\Examen

# Installer BFG Repo-Cleaner (si pas déjà fait)
# Télécharger depuis: https://rtyley.github.io/bfg-repo-cleaner/

# Ou utiliser git filter-repo
pip install git-filter-repo

# Supprimer les credentials de l'historique
git filter-repo --invert-paths --path docs/CONFIGURER-AWS-CLI.md

# Force push (ATTENTION: destructif!)
git push origin main --force
```

**Alternative plus simple:** Supprimer le fichier problématique:

```bash
# Supprimer le fichier
git rm docs/CONFIGURER-AWS-CLI.md

# Commit
git commit -m "security: remove file with exposed credentials"

# Push
git push origin main
```

---

## 📋 CHECKLIST URGENTE

- [ ] Credentials `AKIA3A7OI7EFZMQTRDMA` supprimées dans AWS
- [ ] Nouvel utilisateur IAM créé
- [ ] Nouvelles Access Keys générées
- [ ] Nouvelles credentials testées localement
- [ ] GitHub Secrets mis à jour
- [ ] Fichier problématique supprimé ou historique nettoyé
- [ ] Vérification: aucune credential dans le code

---

## 🔒 BONNES PRATIQUES POUR L'AVENIR

### ❌ NE JAMAIS FAIRE:

1. **Ne JAMAIS mettre de vraies credentials dans:**
   - Fichiers de code
   - Fichiers de documentation
   - Fichiers de configuration
   - Commentaires
   - README
   - Exemples

2. **Ne JAMAIS commiter:**
   - `.env` avec vraies valeurs
   - `credentials.json`
   - Fichiers de configuration AWS
   - Clés API

### ✅ TOUJOURS FAIRE:

1. **Utiliser des exemples génériques:**
   ```
   AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
   AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
   ```

2. **Utiliser des placeholders:**
   ```
   AWS_ACCESS_KEY_ID=<your-access-key-here>
   AWS_SECRET_ACCESS_KEY=<your-secret-key-here>
   ```

3. **Utiliser GitHub Secrets** pour les vraies credentials

4. **Utiliser `.gitignore`:**
   ```
   .env
   .env.local
   credentials.json
   *.pem
   *.key
   ```

5. **Activer GitHub Secret Scanning** (déjà fait!)

---

## 🛡️ VÉRIFICATION DE SÉCURITÉ

### Vérifier qu'aucune credential n'est exposée:

```bash
cd c:\Users\KENNETH\Desktop\Examen

# Chercher des patterns de credentials AWS
git grep -i "AKIA"
git grep -i "aws_access_key"
git grep -i "aws_secret"

# Vérifier les fichiers .env
git ls-files | grep -i "\.env"
```

**Résultat attendu:** Aucun résultat (ou seulement des exemples)

---

## 📞 SI VOUS VOYEZ DES ACTIVITÉS SUSPECTES

### Vérifier les logs AWS:

1. **CloudTrail:**
   ```
   https://console.aws.amazon.com/cloudtrail/
   ```

2. **Chercher des événements avec la clé exposée**

3. **Vérifier les ressources créées:**
   - EC2 instances
   - S3 buckets
   - Lambda functions
   - Autres services

### Si activité suspecte détectée:

1. **Supprimer immédiatement toutes les Access Keys**
2. **Contacter le support AWS**
3. **Activer MFA sur le compte root**
4. **Changer le mot de passe root**
5. **Vérifier la facture AWS**

---

## 💰 VÉRIFIER LES COÛTS

```
https://console.aws.amazon.com/billing/home#/bills
```

- Vérifier qu'il n'y a pas de charges inattendues
- Activer les alertes de facturation
- Définir un budget AWS

---

## 🎯 RÉSUMÉ

**Problème:** Credentials AWS exposées sur GitHub
**Impact:** Risque de sécurité élevé
**Action:** Révoquer immédiatement + créer nouvelles credentials
**Temps:** 5-10 minutes
**Priorité:** 🚨 CRITIQUE

---

## ✅ APRÈS RÉSOLUTION

Une fois les credentials révoquées et remplacées:

1. ✅ Les anciennes credentials ne fonctionnent plus
2. ✅ Les nouvelles credentials sont sécurisées dans GitHub Secrets
3. ✅ Aucune credential dans le code
4. ✅ Pipeline peut fonctionner avec les nouvelles credentials

**Vous pouvez maintenant continuer en toute sécurité!**
