# Guide de Dépannage - Pipeline CI/CD GitHub Actions

## Problème : "This job was skipped" sur deploy-aws

### Causes Possibles

#### 1. Condition `if: false` (RÉSOLU ✅)

**Problème** : Le job était désactivé avec `if: false`

**Solution** : Modifier la condition pour :
```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

#### 2. Branche incorrecte

**Problème** : Le déploiement ne se fait que sur la branche `main`

**Vérification** :
```bash
# Vérifier votre branche actuelle
git branch

# Si vous êtes sur 'develop' ou autre, le déploiement sera skippé
```

**Solution** :
```bash
# Option 1 : Pousser sur main
git checkout main
git merge develop
git push origin main

# Option 2 : Modifier la condition pour inclure develop
if: (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop') && github.event_name == 'push'
```

#### 3. Type d'événement incorrect

**Problème** : Le déploiement ne se fait pas sur les Pull Requests

**Explication** :
- `github.event_name == 'push'` : Déploie uniquement sur push direct
- `github.event_name == 'pull_request'` : Événement de PR

**Solution** : C'est normal ! Les PR ne doivent pas déployer en production.

#### 4. Jobs précédents échoués

**Problème** : Si `test-backend`, `lint-and-security` ou `build-docker` échouent, le déploiement est skippé

**Vérification** :
```yaml
needs: [test-backend, lint-and-security, build-docker]
```

**Solution** :
1. Vérifier les logs des jobs précédents
2. Corriger les erreurs
3. Re-pousser le code

#### 5. Secrets AWS manquants

**Problème** : Les secrets AWS ne sont pas configurés dans GitHub

**Secrets requis** :
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `S3_BUCKET_NAME`
- `CLOUDFRONT_DISTRIBUTION_ID`

**Solution** :
1. Aller dans **Settings** → **Secrets and variables** → **Actions**
2. Cliquer sur **New repository secret**
3. Ajouter chaque secret :

```
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
S3_BUCKET_NAME=digitrans-crm-frontend
CLOUDFRONT_DISTRIBUTION_ID=E1234567890ABC
```

---

## Solutions par Scénario

### Scénario 1 : Développement Local (Branche develop)

**Comportement attendu** : Le déploiement est skippé ✅

**Raison** : Seule la branche `main` déclenche le déploiement en production

**Workflow** :
```
develop → Tests OK → Build OK → Deploy SKIPPED ✅
main    → Tests OK → Build OK → Deploy AWS ✅
```

**Si vous voulez déployer depuis develop** :

```yaml
deploy-aws-staging:
  name: Deploy to AWS Staging
  runs-on: ubuntu-latest
  needs: [test-backend, lint-and-security, build-docker]
  if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
  
  steps:
    - name: Deploy to Staging
      run: |
        # Déployer sur environnement staging
        aws s3 sync frontend/ s3://digitrans-crm-staging/
```

### Scénario 2 : Pull Request

**Comportement attendu** : Le déploiement est skippé ✅

**Raison** : Les PR ne doivent pas déployer automatiquement

**Workflow** :
```
PR → Tests OK → Build OK → Deploy SKIPPED ✅
```

**C'est normal et souhaité !**

### Scénario 3 : Push sur main (Production)

**Comportement attendu** : Le déploiement s'exécute ✅

**Workflow** :
```
main → Tests OK → Build OK → Deploy AWS ✅
```

**Si le déploiement est toujours skippé** :

1. **Vérifier la branche** :
```bash
git branch
# Doit afficher : * main
```

2. **Vérifier les secrets** :
```bash
# Dans GitHub : Settings → Secrets → Actions
# Vérifier que AWS_ACCESS_KEY_ID existe
```

3. **Vérifier les logs GitHub Actions** :
```
Actions → Votre workflow → deploy-aws
# Regarder la section "Set up job" pour voir la condition
```

---

## Configuration Recommandée

### Option 1 : Déploiement Simple (Main uniquement)

```yaml
deploy-aws:
  name: Deploy to AWS Production
  runs-on: ubuntu-latest
  needs: [test-backend, lint-and-security, build-docker]
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  
  steps:
    - name: Deploy
      run: echo "Deploying to production..."
```

**Résultat** :
- ✅ Push sur `main` → Déploie
- ⏭️ Push sur `develop` → Skip
- ⏭️ Pull Request → Skip

### Option 2 : Déploiement Multi-Environnements

```yaml
deploy-staging:
  name: Deploy to Staging
  if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
  steps:
    - run: echo "Deploy to staging"

deploy-production:
  name: Deploy to Production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  steps:
    - run: echo "Deploy to production"
```

**Résultat** :
- ✅ Push sur `main` → Déploie en production
- ✅ Push sur `develop` → Déploie en staging
- ⏭️ Pull Request → Skip

### Option 3 : Déploiement Manuel (Recommandé pour Production)

```yaml
deploy-production:
  name: Deploy to Production
  runs-on: ubuntu-latest
  needs: [test-backend, lint-and-security, build-docker]
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  environment:
    name: production
    url: https://crm.agrocam.cm
  
  steps:
    - name: Deploy
      run: echo "Deploying..."
```

**Avantage** : Nécessite une approbation manuelle dans GitHub

**Configuration** :
1. **Settings** → **Environments** → **New environment**
2. Nom : `production`
3. Cocher **Required reviewers**
4. Ajouter des reviewers

**Résultat** :
- Push sur `main` → Attend approbation → Déploie ✅

---

## Commandes de Diagnostic

### 1. Vérifier la branche actuelle
```bash
git branch
git status
```

### 2. Vérifier les secrets GitHub
```bash
# Via GitHub CLI (si installé)
gh secret list

# Ou via l'interface web
# https://github.com/VOTRE_USERNAME/VOTRE_REPO/settings/secrets/actions
```

### 3. Tester localement le workflow
```bash
# Installer act (https://github.com/nektos/act)
choco install act-cli

# Tester le workflow
act push -j deploy-aws --secret-file .secrets
```

### 4. Vérifier les logs GitHub Actions
```bash
# Via GitHub CLI
gh run list
gh run view RUN_ID --log

# Ou via l'interface web
# https://github.com/VOTRE_USERNAME/VOTRE_REPO/actions
```

---

## Checklist de Vérification

### Avant de Pousser

- [ ] Je suis sur la bonne branche (`main` pour production)
- [ ] Les tests passent localement
- [ ] Le code est formaté (Black, Prettier)
- [ ] Les secrets AWS sont configurés dans GitHub
- [ ] Le bucket S3 existe
- [ ] La distribution CloudFront existe

### Après le Push

- [ ] Le workflow démarre automatiquement
- [ ] Les tests passent (job `test-backend`)
- [ ] Le linting passe (job `lint-and-security`)
- [ ] Le build Docker réussit (job `build-docker`)
- [ ] Le déploiement s'exécute (job `deploy-aws`)
- [ ] Le site est accessible

### Si le Déploiement est Skippé

1. **Vérifier la branche** :
   ```bash
   git branch
   # Doit être sur 'main' pour production
   ```

2. **Vérifier le type d'événement** :
   - Push direct → Déploie ✅
   - Pull Request → Skip ⏭️

3. **Vérifier les jobs précédents** :
   - Tous doivent être verts ✅

4. **Vérifier la condition `if`** :
   ```yaml
   if: github.ref == 'refs/heads/main' && github.event_name == 'push'
   ```

---

## Exemples de Workflows

### Workflow Actuel (Corrigé)

```yaml
deploy-aws:
  name: Deploy to AWS
  runs-on: ubuntu-latest
  needs: [test-backend, lint-and-security, build-docker]
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  
  steps:
    - name: Deploy Frontend
      run: aws s3 sync frontend/ s3://digitrans-crm-frontend/
    
    - name: Invalidate CloudFront
      run: aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths "/*"
```

### Workflow avec Environnements Multiples

```yaml
deploy:
  name: Deploy
  runs-on: ubuntu-latest
  needs: [test-backend, build-docker]
  if: github.event_name == 'push'
  
  strategy:
    matrix:
      environment:
        - name: staging
          branch: develop
          bucket: digitrans-crm-staging
        - name: production
          branch: main
          bucket: digitrans-crm-frontend
  
  steps:
    - name: Deploy to ${{ matrix.environment.name }}
      if: github.ref == format('refs/heads/{0}', matrix.environment.branch)
      run: |
        aws s3 sync frontend/ s3://${{ matrix.environment.bucket }}/
```

---

## Ressources

### Documentation GitHub Actions
- **Conditions** : https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idif
- **Contexts** : https://docs.github.com/en/actions/learn-github-actions/contexts
- **Secrets** : https://docs.github.com/en/actions/security-guides/encrypted-secrets

### Outils
- **GitHub CLI** : https://cli.github.com/
- **Act (test local)** : https://github.com/nektos/act
- **AWS CLI** : https://aws.amazon.com/cli/

### Tutoriels
- **GitHub Actions CI/CD** : https://docs.github.com/en/actions/deployment/about-deployments
- **Deploy to AWS** : https://github.com/aws-actions

---

## Support

### Si le problème persiste

1. **Vérifier les logs détaillés** :
   - Actions → Votre workflow → deploy-aws
   - Cliquer sur "Set up job" pour voir les conditions

2. **Activer le debug** :
   ```yaml
   env:
     ACTIONS_STEP_DEBUG: true
     ACTIONS_RUNNER_DEBUG: true
   ```

3. **Tester avec une condition simplifiée** :
   ```yaml
   if: github.event_name == 'push'
   # Déploie sur tous les push (pour tester)
   ```

4. **Contacter le support** :
   - GitHub Community : https://github.community/
   - Stack Overflow : https://stackoverflow.com/questions/tagged/github-actions

---

**Document créé par** : CAMTECH SOLUTIONS S.A.  
**Date** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Problème résolu
