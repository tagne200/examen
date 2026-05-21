# Pipeline CI/CD - DIGITRANS-CM

## 📋 Vue d'Ensemble

Ce pipeline automatise les tests, le build et le déploiement de l'application CRM DIGITRANS-CM.

## 🔄 Workflow

```
Push/PR → Tests → Lint → Build → Deploy (si main)
```

## 🎯 Jobs du Pipeline

### 1. test-backend ✅
**Durée** : ~2 minutes  
**Déclencheur** : Tous les push et PR

**Actions** :
- Lance PostgreSQL en service
- Installe les dépendances Python
- Initialise la base de données
- Exécute les tests avec pytest
- Génère le rapport de couverture
- Upload vers Codecov

**Conditions de succès** :
- Tous les tests passent
- Couverture > 0% (idéalement > 80%)

### 2. lint-and-security ⚠️
**Durée** : ~1 minute  
**Déclencheur** : Tous les push et PR

**Actions** :
- Black : Vérification du formatage
- Flake8 : Linting Python
- Bandit : Scan de sécurité
- Safety : Vérification des dépendances

**Note** : `continue-on-error: true` → N'empêche pas le déploiement

### 3. build-docker 🐳
**Durée** : ~3 minutes  
**Déclencheur** : Tous les push et PR  
**Dépend de** : test-backend

**Actions** :
- Build de l'image Docker
- Tag avec le SHA du commit
- Test de l'image

### 4. deploy-aws 🚀
**Durée** : ~2 minutes  
**Déclencheur** : Push sur `main` uniquement  
**Dépend de** : test-backend, lint-and-security, build-docker

**Actions** :
- Déploie le frontend sur S3
- Invalide le cache CloudFront
- Déploie le backend sur Lambda (optionnel)

**Condition** :
```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### 5. notify 📧
**Durée** : ~10 secondes  
**Déclencheur** : Toujours (après deploy-aws)

**Actions** :
- Affiche le statut du pipeline
- Peut envoyer des notifications (à configurer)

## 🔐 Secrets Requis

| Secret | Description | Exemple |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | Clé d'accès AWS | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Clé secrète AWS | `wJalrXUtnFEMI/K7MDENG/...` |
| `S3_BUCKET_NAME` | Nom du bucket S3 | `digitrans-crm-frontend` |
| `CLOUDFRONT_DISTRIBUTION_ID` | ID CloudFront | `E1234567890ABC` |

**Configuration** : Settings → Secrets and variables → Actions

## 📊 Matrice de Déploiement

| Branche | Tests | Build | Deploy | Environnement |
|---------|-------|-------|--------|---------------|
| `develop` | ✅ | ✅ | ⏭️ Skip | - |
| `main` | ✅ | ✅ | ✅ | Production |
| `feature/*` | ✅ | ✅ | ⏭️ Skip | - |
| Pull Request | ✅ | ✅ | ⏭️ Skip | - |

## 🐛 Dépannage

### Le déploiement est skippé

**Causes possibles** :
1. Vous n'êtes pas sur la branche `main`
2. C'est une Pull Request (normal)
3. Les secrets AWS ne sont pas configurés
4. Un job précédent a échoué

**Solution** : Voir [TROUBLESHOOTING-CICD.md](../../docs/TROUBLESHOOTING-CICD.md)

### Les tests échouent

```bash
# Tester localement
cd backend
pytest tests/ -v

# Vérifier la base de données
docker-compose up -d postgres
python -m app.database init
```

### Le build Docker échoue

```bash
# Tester localement
cd backend
docker build -t test .
docker run --rm test python --version
```

## 🔧 Modification du Pipeline

### Ajouter un environnement staging

```yaml
deploy-staging:
  name: Deploy to Staging
  runs-on: ubuntu-latest
  needs: [test-backend, build-docker]
  if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
  
  steps:
    - name: Deploy to Staging
      run: |
        aws s3 sync frontend/ s3://digitrans-crm-staging/
```

### Ajouter des notifications Slack

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

### Activer le déploiement manuel

```yaml
deploy-production:
  environment:
    name: production
    url: https://crm.agrocam.cm
  # Nécessite une approbation manuelle
```

## 📈 Métriques

### Temps d'Exécution Moyen

- **Total** : ~8 minutes
- Tests : 2 min
- Lint : 1 min
- Build : 3 min
- Deploy : 2 min

### Taux de Succès

- **Objectif** : > 95%
- **Actuel** : À mesurer

## 🔗 Ressources

- **GitHub Actions** : https://docs.github.com/en/actions
- **AWS Actions** : https://github.com/aws-actions
- **Codecov** : https://codecov.io/

## 📝 Changelog

### v1.0.0 (2025-01-20)
- ✅ Pipeline initial
- ✅ Tests backend
- ✅ Linting et sécurité
- ✅ Build Docker
- ✅ Déploiement AWS

### v1.1.0 (2025-01-21)
- ✅ Correction condition déploiement (`if: false` → condition correcte)
- ✅ Ajout documentation dépannage

---

**Maintenu par** : CAMTECH SOLUTIONS S.A.  
**Contact** : devops@camtech-solutions.cm  
**Dernière mise à jour** : Janvier 2025
