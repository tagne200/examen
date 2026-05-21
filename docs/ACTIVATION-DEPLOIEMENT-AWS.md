# 🚀 Activation du Déploiement AWS - Guide Rapide

## ✅ Problème Résolu

Le job `deploy-aws` était **skippé** car il avait la condition `if: false`.

**Correction appliquée** : La condition a été changée pour :
```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

---

## 📋 Prérequis pour le Déploiement

### 1. Secrets GitHub (OBLIGATOIRE)

Avant que le déploiement fonctionne, vous devez configurer les secrets AWS dans GitHub :

#### Étapes :

1. **Aller dans les paramètres du repository** :
   ```
   https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions
   ```

2. **Cliquer sur "New repository secret"**

3. **Ajouter les secrets suivants** :

| Nom du Secret | Valeur | Description |
|---------------|--------|-------------|
| `AWS_ACCESS_KEY_ID` | `AKIAIOSFODNN7EXAMPLE` | Clé d'accès AWS |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI/K7MDENG/...` | Clé secrète AWS |
| `S3_BUCKET_NAME` | `digitrans-crm-frontend` | Nom du bucket S3 |
| `CLOUDFRONT_DISTRIBUTION_ID` | `E1234567890ABC` | ID CloudFront |

#### Comment obtenir ces valeurs ?

**AWS_ACCESS_KEY_ID et AWS_SECRET_ACCESS_KEY** :
```bash
# Via AWS CLI
aws iam create-access-key --user-name github-actions

# Ou via Console AWS
# IAM → Users → github-actions → Security credentials → Create access key
```

**S3_BUCKET_NAME** :
```bash
# Lister vos buckets
aws s3 ls

# Ou créer un nouveau bucket
aws s3 mb s3://digitrans-crm-frontend --region af-south-1
```

**CLOUDFRONT_DISTRIBUTION_ID** :
```bash
# Lister vos distributions
aws cloudfront list-distributions --query 'DistributionList.Items[*].[Id,DomainName]' --output table

# Ou via Console AWS
# CloudFront → Distributions → Copier l'ID
```

---

## 🔄 Workflow de Déploiement

### Comportement Actuel

```
┌─────────────────────────────────────────────────────────┐
│ Push sur 'develop'                                      │
│  ↓                                                      │
│  Tests Backend ✅                                       │
│  Lint & Security ✅                                     │
│  Build Docker ✅                                        │
│  Deploy AWS ⏭️ SKIPPED (normal, pas sur main)         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Push sur 'main'                                         │
│  ↓                                                      │
│  Tests Backend ✅                                       │
│  Lint & Security ✅                                     │
│  Build Docker ✅                                        │
│  Deploy AWS ✅ DÉPLOIE (si secrets configurés)         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Pull Request                                            │
│  ↓                                                      │
│  Tests Backend ✅                                       │
│  Lint & Security ✅                                     │
│  Build Docker ✅                                        │
│  Deploy AWS ⏭️ SKIPPED (normal, pas de déploiement)   │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Comment Déclencher un Déploiement

### Option 1 : Push Direct sur Main (Recommandé)

```bash
# 1. S'assurer d'être sur main
git checkout main

# 2. Merger develop (ou faire vos modifications)
git merge develop

# 3. Pousser
git push origin main

# 4. Le déploiement démarre automatiquement
# Vérifier sur : https://github.com/VOTRE_REPO/actions
```

### Option 2 : Via Pull Request + Merge

```bash
# 1. Créer une PR depuis develop vers main
git checkout develop
git push origin develop

# 2. Sur GitHub : Create Pull Request
# develop → main

# 3. Attendre les tests (tous doivent passer ✅)

# 4. Merger la PR

# 5. Le déploiement démarre automatiquement sur main
```

### Option 3 : Déploiement Manuel (Si configuré)

```bash
# Via GitHub CLI
gh workflow run ci-cd.yml --ref main

# Ou via l'interface GitHub
# Actions → CI/CD Pipeline → Run workflow → main
```

---

## 🔍 Vérifier le Statut du Déploiement

### Via GitHub Actions

1. **Aller sur** : `https://github.com/VOTRE_REPO/actions`
2. **Cliquer sur le dernier workflow**
3. **Vérifier chaque job** :
   - ✅ test-backend
   - ✅ lint-and-security
   - ✅ build-docker
   - ✅ deploy-aws (doit être vert, pas skippé)

### Via AWS CLI

```bash
# Vérifier le bucket S3
aws s3 ls s3://digitrans-crm-frontend/

# Vérifier la dernière invalidation CloudFront
aws cloudfront list-invalidations --distribution-id E1234567890ABC

# Tester le site
curl https://votre-cloudfront-url.cloudfront.net
```

---

## ⚠️ Cas où le Déploiement est Toujours Skippé

### Cause 1 : Vous n'êtes pas sur 'main'

**Vérification** :
```bash
git branch
# Doit afficher : * main
```

**Solution** :
```bash
git checkout main
git push origin main
```

### Cause 2 : C'est une Pull Request

**Explication** : Les PR ne déploient pas automatiquement (c'est normal ✅)

**Solution** : Merger la PR, puis le déploiement se fera sur main

### Cause 3 : Les secrets AWS manquent

**Vérification** :
```bash
# Via GitHub CLI
gh secret list

# Doit afficher :
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# S3_BUCKET_NAME
# CLOUDFRONT_DISTRIBUTION_ID
```

**Solution** : Ajouter les secrets (voir section Prérequis)

### Cause 4 : Un job précédent a échoué

**Vérification** : Regarder les logs GitHub Actions

**Solution** : Corriger l'erreur et re-pousser

---

## 🧪 Tester Sans AWS (Mode Développement)

Si vous n'avez pas encore de compte AWS, vous pouvez tester localement :

### Option 1 : Désactiver temporairement le déploiement

```yaml
deploy-aws:
  if: false  # Désactiver temporairement
```

### Option 2 : Simuler le déploiement

```yaml
deploy-aws:
  steps:
    - name: Simulate deployment
      run: |
        echo "✅ Frontend would be deployed to S3"
        echo "✅ CloudFront would be invalidated"
        echo "✅ Backend would be deployed to Lambda"
```

### Option 3 : Déployer localement avec Docker

```bash
# Démarrer l'infrastructure locale
docker-compose up -d

# Tester le frontend
curl http://localhost/

# Tester le backend
curl http://localhost:8000/health
```

---

## 📊 Monitoring du Déploiement

### Logs en Temps Réel

```bash
# Via GitHub CLI
gh run watch

# Ou via l'interface web
# Actions → Votre workflow → Cliquer sur le job en cours
```

### Notifications

**Configurer les notifications GitHub** :
1. **Settings** → **Notifications**
2. Cocher **Actions**
3. Choisir **Email** ou **Web**

**Ajouter Slack/Discord** (optionnel) :
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🎓 Bonnes Pratiques

### 1. Toujours Tester Avant de Déployer

```bash
# Tests locaux
cd backend
pytest tests/

# Build Docker local
docker build -t test .
docker run --rm test python --version
```

### 2. Utiliser des Branches

```
develop → Tests → Staging (auto)
   ↓
  PR
   ↓
main → Tests → Production (auto ou manuel)
```

### 3. Protéger la Branche Main

**Settings** → **Branches** → **Add rule** :
- Branch name pattern : `main`
- ✅ Require pull request reviews
- ✅ Require status checks to pass
- ✅ Require branches to be up to date

### 4. Utiliser des Environnements GitHub

**Settings** → **Environments** → **New environment** :
- Nom : `production`
- ✅ Required reviewers (vous-même)
- ✅ Wait timer : 5 minutes

**Avantage** : Approbation manuelle avant déploiement

---

## 🔗 Ressources Utiles

### Documentation
- **GitHub Actions** : https://docs.github.com/en/actions
- **AWS CLI** : https://docs.aws.amazon.com/cli/
- **Terraform** : https://www.terraform.io/docs

### Tutoriels
- **Deploy to AWS S3** : https://github.com/aws-actions/configure-aws-credentials
- **CloudFront Invalidation** : https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html

### Outils
- **GitHub CLI** : https://cli.github.com/
- **AWS CLI** : https://aws.amazon.com/cli/
- **Act (test local)** : https://github.com/nektos/act

---

## ✅ Checklist Finale

### Avant le Premier Déploiement

- [ ] Secrets AWS configurés dans GitHub
- [ ] Bucket S3 créé (`digitrans-crm-frontend`)
- [ ] Distribution CloudFront créée
- [ ] Branche `main` protégée
- [ ] Tests passent localement
- [ ] Workflow modifié (`if: false` → condition correcte)

### Pour Chaque Déploiement

- [ ] Code testé localement
- [ ] Commit avec message clair
- [ ] Push sur `main` (ou merge PR)
- [ ] Vérifier GitHub Actions
- [ ] Vérifier le site déployé
- [ ] Tester les fonctionnalités

---

## 🎉 Résumé

**Problème** : `deploy-aws` était skippé  
**Cause** : Condition `if: false`  
**Solution** : Condition changée en `if: github.ref == 'refs/heads/main' && github.event_name == 'push'`  

**Prochaines étapes** :
1. ✅ Configurer les secrets AWS dans GitHub
2. ✅ Pousser sur `main`
3. ✅ Vérifier que le déploiement s'exécute
4. ✅ Tester le site déployé

**Le déploiement est maintenant activé ! 🚀**

---

**Document créé par** : CAMTECH SOLUTIONS S.A.  
**Date** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Prêt à déployer
