# 🎯 GitHub Actions - Guide Rapide (5 Minutes)

## ✅ ÉTAPES ESSENTIELLES

### 1️⃣ Créer Repository GitHub (2 min)

1. Aller sur https://github.com
2. Cliquer **+** → **New repository**
3. Nom : `digitrans-cm-crm`
4. Cliquer **Create repository**
5. Copier l'URL : `https://github.com/TON-USERNAME/digitrans-cm-crm.git`

---

### 2️⃣ Pousser le Code (2 min)

```bash
cd c:\Users\KENNETH\Desktop\Examen

git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/TON-USERNAME/digitrans-cm-crm.git
git push -u origin main
```

**Note** : Remplacer `TON-USERNAME` par ton vrai username GitHub

---

### 3️⃣ Configurer les Secrets (1 min)

Sur GitHub :
1. **Settings** → **Secrets and variables** → **Actions**
2. Ajouter 3 secrets :
   - `AWS_ACCESS_KEY_ID` : Ta clé AWS
   - `AWS_SECRET_ACCESS_KEY` : Ta clé secrète AWS
   - `S3_BUCKET_NAME` : `digitrans-crm-frontend`

---

### 4️⃣ Voir le Pipeline

1. Onglet **Actions** sur GitHub
2. Le pipeline se lance automatiquement
3. Attendre 5-10 minutes
4. Vérifier que tout est ✅ vert

---

## 🔧 COMMANDES UTILES

```bash
# Voir le statut
git status

# Faire un commit
git add .
git commit -m "Mon message"
git push origin main

# Voir l'historique
git log --oneline

# Créer une branche
git checkout -b ma-branche
```

---

## 📊 RÉSULTAT ATTENDU

```
✅ test-backend          (2-3 min)
✅ lint-and-security     (1-2 min)
✅ build-docker          (2-3 min)
⏸️ deploy-aws            (désactivé)
✅ notify                (< 1 min)
```

---

## 🆘 PROBLÈMES COURANTS

**Erreur d'authentification Git ?**
→ Créer un Personal Access Token : https://github.com/settings/tokens

**Tests échouent ?**
→ Voir les logs dans Actions → Cliquer sur le job rouge

**Secrets manquants ?**
→ Vérifier Settings → Secrets and variables → Actions

---

## 📚 LIENS UTILES

- **Documentation** : https://docs.github.com/en/actions
- **Tutoriel vidéo** : https://www.youtube.com/watch?v=R8_veQiYBjI
- **Marketplace** : https://github.com/marketplace?type=actions

---

## ✨ C'EST TOUT !

Ton pipeline CI/CD est maintenant configuré et fonctionnel ! 🚀

À chaque `git push`, les tests s'exécutent automatiquement.
