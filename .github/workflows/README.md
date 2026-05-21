# GitHub Actions CI/CD Pipeline

## Vue d'Ensemble

Ce pipeline automatise les tests, la sécurité, le build et le déploiement du projet DIGITRANS-CM CRM.

## Workflows

### 1. Test Backend (`test-backend`)
- **Déclenchement** : Push sur `main` ou `develop`, Pull Request
- **Actions** :
  - Démarre une base PostgreSQL 15 en service
  - Installe les dépendances Python
  - Initialise la base de données
  - Exécute les tests avec pytest
  - Génère un rapport de couverture
  - Upload vers Codecov

### 2. Linting & Security (`lint-and-security`)
- **Déclenchement** : Push sur `main` ou `develop`, Pull Request
- **Actions** :
  - **Black** : Vérification du formatage du code
  - **Flake8** : Linting Python
  - **Bandit** : Scan de sécurité
  - **Safety** : Vérification des vulnérabilités des dépendances

### 3. Build Docker (`build-docker`)
- **Déclenchement** : Après succès des tests
- **Actions** :
  - Build de l'image Docker
  - Tag avec le SHA du commit
  - Test de l'image

### 4. Deploy AWS (`deploy-aws`)
- **Déclenchement** : Push sur `main` uniquement
- **Actions** :
  - Déploiement du frontend sur S3
  - Invalidation du cache CloudFront
  - Déploiement du backend sur Lambda (optionnel)

### 5. Notification (`notify`)
- **Déclenchement** : Toujours (après tous les jobs)
- **Actions** :
  - Envoi de notification de statut

## Configuration des Secrets GitHub

Pour que le pipeline fonctionne, configurer les secrets suivants dans GitHub :

### Secrets Requis

1. **AWS Credentials**
   ```
   AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
   AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

2. **AWS Resources**
   ```
   S3_BUCKET_NAME=digitrans-crm-frontend
   CLOUDFRONT_DISTRIBUTION_ID=E1XXXXXXXXXXXXX
   ```

3. **Database (optionnel pour tests)**
   ```
   DATABASE_URL=postgresql://user:pass@host:5432/db
   ```

4. **Azure AD (optionnel)**
   ```
   AZURE_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   AZURE_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   AZURE_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

## Comment Configurer les Secrets

### Via l'Interface GitHub

1. Aller dans votre repository GitHub
2. Cliquer sur **Settings** → **Secrets and variables** → **Actions**
3. Cliquer sur **New repository secret**
4. Ajouter chaque secret avec son nom et sa valeur

### Via GitHub CLI

```bash
gh secret set AWS_ACCESS_KEY_ID -b"AKIAXXXXXXXXXXXXXXXX"
gh secret set AWS_SECRET_ACCESS_KEY -b"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
gh secret set S3_BUCKET_NAME -b"digitrans-crm-frontend"
gh secret set CLOUDFRONT_DISTRIBUTION_ID -b"E1XXXXXXXXXXXXX"
```

## Badges de Statut

Ajouter ces badges dans votre README.md :

```markdown
![CI/CD Pipeline](https://github.com/votre-username/digitrans-crm/actions/workflows/ci-cd.yml/badge.svg)
![Coverage](https://codecov.io/gh/votre-username/digitrans-crm/branch/main/graph/badge.svg)
```

## Déclenchement Manuel

Pour déclencher manuellement le workflow :

```bash
# Via GitHub CLI
gh workflow run ci-cd.yml

# Via l'interface GitHub
Actions → CI/CD Pipeline → Run workflow
```

## Logs et Debugging

### Voir les logs d'un workflow

```bash
gh run list
gh run view <run-id>
gh run view <run-id> --log
```

### Débugger un échec

1. Aller dans **Actions** sur GitHub
2. Cliquer sur le workflow échoué
3. Cliquer sur le job échoué
4. Examiner les logs détaillés

## Optimisations

### Cache des Dépendances

Le pipeline utilise le cache pour accélérer les builds :
- Cache pip pour Python
- Cache npm pour Node.js (si ajouté)

### Exécution Parallèle

Les jobs `test-backend` et `lint-and-security` s'exécutent en parallèle pour gagner du temps.

### Exécution Conditionnelle

Le job `deploy-aws` ne s'exécute que :
- Sur la branche `main`
- Après succès de tous les tests
- Sur un push (pas sur PR)

## Temps d'Exécution Estimé

- **test-backend** : 2-3 minutes
- **lint-and-security** : 1-2 minutes
- **build-docker** : 2-3 minutes
- **deploy-aws** : 1-2 minutes

**Total** : ~6-10 minutes

## Notifications

### Slack (optionnel)

Ajouter ce step dans le job `notify` :

```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Pipeline ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  if: always()
```

### Email (optionnel)

GitHub envoie automatiquement des emails en cas d'échec.

## Sécurité

### Bonnes Pratiques

✅ Utiliser des secrets pour les credentials
✅ Ne jamais commit de tokens ou mots de passe
✅ Limiter les permissions des tokens AWS
✅ Utiliser des environnements GitHub pour la production
✅ Activer la protection de branche sur `main`

### Scan de Sécurité

Le pipeline inclut :
- **Bandit** : Détection de vulnérabilités Python
- **Safety** : Vérification des dépendances
- **Dependabot** : Mises à jour automatiques (à activer)

## Environnements GitHub

Créer des environnements pour séparer dev/staging/prod :

1. **Settings** → **Environments** → **New environment**
2. Créer `production`, `staging`, `development`
3. Configurer les secrets par environnement
4. Ajouter des règles de protection (approbation requise)

## Rollback

En cas de problème après déploiement :

```bash
# Revenir au commit précédent
git revert HEAD
git push origin main

# Ou redéployer une version spécifique
gh workflow run ci-cd.yml --ref <commit-sha>
```

## Monitoring

### GitHub Actions Insights

- **Actions** → **Workflows** → **CI/CD Pipeline**
- Voir les statistiques d'exécution
- Temps moyen, taux de succès, etc.

### Codecov

- Voir la couverture de code sur https://codecov.io
- Intégration automatique avec le pipeline

## Troubleshooting

### Erreur : "PostgreSQL connection refused"

**Solution** : Vérifier que le service PostgreSQL est bien démarré dans le workflow.

### Erreur : "AWS credentials not found"

**Solution** : Vérifier que les secrets `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` sont configurés.

### Erreur : "S3 bucket not found"

**Solution** : Créer le bucket S3 ou vérifier le nom dans les secrets.

### Tests échouent localement mais pas en CI

**Solution** : Vérifier les variables d'environnement et la version de Python.

## Améliorations Futures

- [ ] Ajouter des tests frontend (Jest, Cypress)
- [ ] Déploiement multi-région
- [ ] Tests de charge (Locust, k6)
- [ ] Scan de conteneurs (Trivy)
- [ ] Déploiement Blue/Green
- [ ] Rollback automatique en cas d'erreur

## Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Actions](https://github.com/aws-actions)
- [Codecov Action](https://github.com/codecov/codecov-action)

---

**Dernière mise à jour** : Janvier 2025
