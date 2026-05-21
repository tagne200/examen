# 🚀 Guide Complet GitHub Actions - Pas à Pas

## ÉTAPE 7 : Activer le Déploiement AWS (Quand Prêt)

Quand tu auras créé ton infrastructure AWS, tu pourras activer le déploiement.

Dans le fichier `.github/workflows/ci-cd.yml`, ligne 169, remplacer :

```yaml
if: false  # Désactivé temporairement - Activer quand AWS est prêt
```

Par :

```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

Puis commit et push :

```bash
git add .github/workflows/ci-cd.yml
git commit -m "Enable AWS deployment in CI/CD pipeline"
git push origin main
```

---

## 📚 RESSOURCES UTILES

### Documentation Officielle

- **GitHub Actions** : https://docs.github.com/en/actions
- **GitHub Actions Marketplace** : https://github.com/marketplace?type=actions
- **Workflow Syntax** : https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions

### Tutoriels Vidéo

- **GitHub Actions Tutorial** : https://www.youtube.com/watch?v=R8_veQiYBjI
- **CI/CD with GitHub Actions** : https://www.youtube.com/watch?v=mFFXuXjVgkU
- **Deploy to AWS with GitHub Actions** : https://www.youtube.com/watch?v=eB0nUzAI7M8

### Articles

- **Getting Started** : https://docs.github.com/en/actions/quickstart
- **AWS Deployment** : https://aws.amazon.com/blogs/containers/create-a-ci-cd-pipeline-for-amazon-ecs-with-github-actions-and-aws-codebuild-tests/

---

## 🎯 CHECKLIST FINALE

### Avant de Commencer
- [ ] Compte GitHub créé
- [ ] Git installé
- [ ] Code dans `c:\Users\KENNETH\Desktop\Examen`

### Configuration GitHub
- [ ] Repository créé sur GitHub
- [ ] Code poussé sur GitHub
- [ ] Fichier `.github/workflows/ci-cd.yml` présent
- [ ] Secrets AWS configurés (3 minimum)

### Tests
- [ ] Pipeline déclenché (commit ou manuel)
- [ ] Job `test-backend` réussi ✅
- [ ] Job `lint-and-security` réussi ✅
- [ ] Job `build-docker` réussi ✅
- [ ] Logs consultés et compris

### Déploiement (Optionnel)
- [ ] Infrastructure AWS créée (RDS, S3, CloudFront)
- [ ] Job `deploy-aws` activé
- [ ] Déploiement réussi ✅

---

## 💡 CONSEILS PRATIQUES

### 1. Commit Souvent

```bash
git add .
git commit -m "Fix: Correction bug authentification"
git push origin main
```

### 2. Utiliser des Branches

```bash
# Créer une branche
git checkout -b feature/nouvelle-fonctionnalite

# Travailler et commit
git add .
git commit -m "Add: Nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite
```

### 3. Voir l'Historique

```bash
git log --oneline -10
git diff
```

### 4. Annuler un Commit

```bash
# Garde les modifications
git reset --soft HEAD~1

# Supprime les modifications
git reset --hard HEAD~1
```

---

## 🎓 POUR ALLER PLUS LOIN

### Ajouter un Badge de Statut

Dans `README.md` :

```markdown
![CI/CD](https://github.com/TON-USERNAME/digitrans-cm-crm/actions/workflows/ci-cd.yml/badge.svg)
```

### Ajouter des Notifications Slack

```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## ❓ FAQ

**Q : Le pipeline est trop long ?**
R : Utiliser le cache pip

**Q : Comment tester localement ?**
R : Utiliser `act` (GitHub Actions local)

**Q : Le pipeline consomme des crédits ?**
R : Gratuit pour repos publics, 2000 min/mois pour privés

---

## 🎉 FÉLICITATIONS !

Pipeline CI/CD complet et automatisé ! 🚀

**À chaque push** :
1. ✅ Tests backend
2. ✅ Analyse sécurité
3. ✅ Build Docker
4. ✅ Déploiement AWS (si activé)
5. ✅ Notification

**Prochaines étapes** :
1. Tester avec un commit
2. Consulter les logs
3. Activer AWS quand prêt
