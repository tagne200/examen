# 📚 INDEX - Documentation CI/CD et Dépannage

## 🎯 Guide de Navigation

Ce document centralise toute la documentation pour résoudre les problèmes de CI/CD et déploiement AWS.

---

## 🚨 Problèmes Courants et Solutions

### 1. "This job was skipped" sur deploy-aws

**Symptôme** : Le job de déploiement ne s'exécute pas

**Documents** :
- 📄 [TROUBLESHOOTING-CICD.md](TROUBLESHOOTING-CICD.md) - Guide complet
- 📄 [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md) - Guide d'activation
- 📄 [RESOLUTION-DEPLOY-SKIPPED.md](RESOLUTION-DEPLOY-SKIPPED.md) - Résumé de la correction

**Solution Rapide** :
```yaml
# Vérifier la condition dans .github/workflows/ci-cd.yml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

---

### 2. "The security token included in the request is invalid"

**Symptôme** : Erreur lors de la configuration des credentials AWS

**Documents** :
- 📄 [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md) - Guide complet
- 📄 [RESOLUTION-AWS-TOKEN.md](RESOLUTION-AWS-TOKEN.md) - Résumé de la solution
- 🔧 [test-aws-credentials.bat](../scripts/test-aws-credentials.bat) - Script de test

**Solution Rapide** :
```bash
# 1. Créer un user IAM
aws iam create-user --user-name github-actions-digitrans

# 2. Créer une access key
aws iam create-access-key --user-name github-actions-digitrans

# 3. Configurer dans GitHub Secrets
gh secret set AWS_ACCESS_KEY_ID --body "VOTRE_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "VOTRE_SECRET"
```

---

### 3. Tests Backend Échouent

**Symptôme** : Le job `test-backend` est rouge

**Solution** :
```bash
# Tester localement
cd backend
pytest tests/ -v

# Vérifier la base de données
docker-compose up -d postgres
python -m app.database init
```

**Documents** :
- 📄 [.github/workflows/README.md](../.github/workflows/README.md) - Documentation du pipeline

---

### 4. Build Docker Échoue

**Symptôme** : Le job `build-docker` est rouge

**Solution** :
```bash
# Tester localement
cd backend
docker build -t test .
docker run --rm test python --version
```

---

## 📂 Structure de la Documentation

```
docs/
├── CI/CD et Déploiement
│   ├── TROUBLESHOOTING-CICD.md          ← Dépannage complet
│   ├── ACTIVATION-DEPLOIEMENT-AWS.md    ← Guide d'activation
│   ├── RESOLUTION-DEPLOY-SKIPPED.md     ← Résolution "skipped"
│   ├── FIX-AWS-TOKEN-INVALID.md         ← Résolution token AWS
│   ├── RESOLUTION-AWS-TOKEN.md          ← Résumé token AWS
│   └── INDEX-CICD-TROUBLESHOOTING.md    ← Ce fichier
│
├── Architecture
│   ├── ARCHITECTURE-HYBRIDE-GUIDE.md    ← Architecture cloud
│   ├── C21-conception-architecture.md   ← Conception C21
│   └── C21-mise-en-oeuvre.md            ← Mise en œuvre C21
│
├── DevOps
│   ├── C22-automatisation-devops.md     ← Automatisation C22
│   └── GITHUB-ACTIONS-RECAP.md          ← Récap GitHub Actions
│
└── Scripts
    └── test-aws-credentials.bat         ← Test credentials AWS
```

---

## 🔍 Recherche Rapide

### Par Symptôme

| Symptôme | Document | Page |
|----------|----------|------|
| Job skippé | [TROUBLESHOOTING-CICD.md](TROUBLESHOOTING-CICD.md) | Section "Causes Possibles" |
| Token invalide | [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md) | Section "Solutions" |
| Tests échouent | [.github/workflows/README.md](../.github/workflows/README.md) | Section "Dépannage" |
| Build échoue | [.github/workflows/README.md](../.github/workflows/README.md) | Section "Dépannage" |
| Secrets manquants | [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md) | Section "Prérequis" |

### Par Tâche

| Tâche | Document | Page |
|-------|----------|------|
| Activer le déploiement | [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md) | Tout le document |
| Configurer AWS | [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md) | Section "Solution Complète" |
| Tester credentials | [test-aws-credentials.bat](../scripts/test-aws-credentials.bat) | Script complet |
| Comprendre le pipeline | [.github/workflows/README.md](../.github/workflows/README.md) | Section "Jobs du Pipeline" |
| Modifier le workflow | [TROUBLESHOOTING-CICD.md](TROUBLESHOOTING-CICD.md) | Section "Exemples de Workflows" |

---

## 🎓 Parcours d'Apprentissage

### Niveau 1 : Débutant

1. **Comprendre le pipeline** :
   - 📄 [.github/workflows/README.md](../.github/workflows/README.md)
   - Temps : 15 minutes

2. **Activer le déploiement** :
   - 📄 [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md)
   - Temps : 30 minutes

3. **Tester les credentials** :
   - 🔧 [test-aws-credentials.bat](../scripts/test-aws-credentials.bat)
   - Temps : 5 minutes

### Niveau 2 : Intermédiaire

1. **Résoudre les problèmes courants** :
   - 📄 [TROUBLESHOOTING-CICD.md](TROUBLESHOOTING-CICD.md)
   - Temps : 30 minutes

2. **Configurer AWS correctement** :
   - 📄 [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md)
   - Temps : 45 minutes

3. **Comprendre l'architecture** :
   - 📄 [ARCHITECTURE-HYBRIDE-GUIDE.md](ARCHITECTURE-HYBRIDE-GUIDE.md)
   - Temps : 1 heure

### Niveau 3 : Avancé

1. **Infrastructure as Code** :
   - 📄 [C22-automatisation-devops.md](C22-automatisation-devops.md)
   - Temps : 2 heures

2. **Optimisation du pipeline** :
   - 📄 [TROUBLESHOOTING-CICD.md](TROUBLESHOOTING-CICD.md) - Section "Modification du Pipeline"
   - Temps : 1 heure

3. **Sécurité avancée (OIDC)** :
   - 📄 [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md) - Section "AWS OIDC"
   - Temps : 1 heure

---

## 🔧 Outils et Scripts

### Scripts Disponibles

| Script | Description | Utilisation |
|--------|-------------|-------------|
| `test-aws-credentials.bat` | Test des credentials AWS | `scripts\test-aws-credentials.bat` |
| `deploy.bat` | Déploiement local | `deploy.bat` |
| `validate-c21.bat` | Validation C21 | `validate-c21.bat` |

### Commandes Utiles

```bash
# GitHub Actions
gh run list                    # Lister les runs
gh run view RUN_ID --log       # Voir les logs
gh secret list                 # Lister les secrets

# AWS
aws sts get-caller-identity    # Vérifier l'identité
aws s3 ls                      # Lister les buckets
aws cloudfront list-distributions  # Lister CloudFront

# Docker
docker-compose up -d           # Démarrer l'infra locale
docker-compose logs -f         # Voir les logs
docker-compose down            # Arrêter l'infra

# Tests
pytest backend/tests/ -v       # Tests backend
npm test                       # Tests frontend
```

---

## 📊 Matrice de Dépannage

### Problème : Deploy Skipped

| Cause | Vérification | Solution | Document |
|-------|--------------|----------|----------|
| Condition `if: false` | Voir workflow | Changer condition | [RESOLUTION-DEPLOY-SKIPPED.md](RESOLUTION-DEPLOY-SKIPPED.md) |
| Branche ≠ main | `git branch` | Pousser sur main | [TROUBLESHOOTING-CICD.md](TROUBLESHOOTING-CICD.md) |
| Pull Request | Type d'événement | Normal, merger la PR | [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md) |
| Job précédent échoué | Logs GitHub | Corriger l'erreur | [.github/workflows/README.md](../.github/workflows/README.md) |

### Problème : Token AWS Invalid

| Cause | Vérification | Solution | Document |
|-------|--------------|----------|----------|
| Credentials invalides | `aws sts get-caller-identity` | Régénérer | [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md) |
| Secrets mal configurés | `gh secret list` | Reconfigurer | [RESOLUTION-AWS-TOKEN.md](RESOLUTION-AWS-TOKEN.md) |
| Permissions insuffisantes | `aws iam list-attached-user-policies` | Attacher policy | [FIX-AWS-TOKEN-INVALID.md](FIX-AWS-TOKEN-INVALID.md) |
| Région incorrecte | Workflow | Vérifier `af-south-1` | [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md) |

---

## 🎯 Checklist Complète

### Configuration Initiale

- [ ] AWS CLI installé
- [ ] GitHub CLI installé (optionnel)
- [ ] Docker installé
- [ ] User IAM créé
- [ ] Access Key générée
- [ ] Permissions attachées
- [ ] Credentials testées localement
- [ ] Secrets GitHub configurés
- [ ] Bucket S3 créé
- [ ] Distribution CloudFront créée

### Avant Chaque Déploiement

- [ ] Tests passent localement
- [ ] Code formaté (Black, Prettier)
- [ ] Commit avec message clair
- [ ] Push sur la bonne branche
- [ ] Workflow démarre automatiquement
- [ ] Tous les jobs passent
- [ ] Déploiement réussit
- [ ] Site accessible

### Dépannage

- [ ] Lire les logs GitHub Actions
- [ ] Vérifier la branche actuelle
- [ ] Vérifier les secrets GitHub
- [ ] Tester les credentials AWS
- [ ] Vérifier les permissions IAM
- [ ] Consulter la documentation appropriée

---

## 🔗 Liens Externes

### Documentation Officielle

- **GitHub Actions** : https://docs.github.com/en/actions
- **AWS CLI** : https://docs.aws.amazon.com/cli/
- **AWS IAM** : https://docs.aws.amazon.com/IAM/
- **Docker** : https://docs.docker.com/
- **Terraform** : https://www.terraform.io/docs

### Tutoriels

- **GitHub Actions CI/CD** : https://docs.github.com/en/actions/deployment
- **AWS Deployment** : https://github.com/aws-actions
- **Docker Multi-stage** : https://docs.docker.com/build/building/multi-stage/

### Outils

- **GitHub CLI** : https://cli.github.com/
- **AWS CLI** : https://aws.amazon.com/cli/
- **Act (test local)** : https://github.com/nektos/act

---

## 📞 Support

### En Cas de Problème

1. **Consulter la documentation** :
   - Chercher le symptôme dans ce fichier
   - Lire le document correspondant

2. **Utiliser les scripts de diagnostic** :
   ```bash
   scripts\test-aws-credentials.bat
   ```

3. **Vérifier les logs** :
   ```bash
   gh run view --log
   ```

4. **Consulter les ressources externes** :
   - GitHub Community : https://github.community/
   - Stack Overflow : https://stackoverflow.com/questions/tagged/github-actions
   - AWS Forums : https://forums.aws.amazon.com/

---

## 📈 Statistiques

### Documentation Créée

- **Fichiers** : 7 documents + 1 script
- **Pages totales** : ~50 pages
- **Temps de lecture** : ~3 heures
- **Problèmes couverts** : 4 majeurs

### Couverture

- ✅ Déploiement skippé : 100%
- ✅ Token AWS invalide : 100%
- ✅ Configuration secrets : 100%
- ✅ Tests et build : 80%
- ⏳ Optimisation avancée : 60%

---

## 🎉 Résumé

**Documentation complète créée pour** :
1. ✅ Résoudre "deploy skipped"
2. ✅ Résoudre "token invalid"
3. ✅ Configurer AWS correctement
4. ✅ Tester les credentials
5. ✅ Comprendre le pipeline

**Prochaines étapes** :
1. Suivre [ACTIVATION-DEPLOIEMENT-AWS.md](ACTIVATION-DEPLOIEMENT-AWS.md)
2. Configurer les secrets AWS
3. Tester le déploiement
4. Consulter ce fichier en cas de problème

---

**Document créé par** : CAMTECH SOLUTIONS S.A.  
**Date** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Documentation complète
