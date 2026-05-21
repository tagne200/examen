# 🚀 Démarrage Rapide - 3 Étapes

## Étape 1️⃣ : Vérifier les Prérequis (2 min)

Double-cliquez sur :
```
check-prereqs.bat
```

**Résultat attendu** : Tous les ✅ verts

**Si ❌ rouge** :
1. Installer Docker Desktop : https://www.docker.com/products/docker-desktop
2. Redémarrer Windows
3. Démarrer Docker Desktop (icône dans la barre des tâches)
4. Relancer `check-prereqs.bat`

---

## Étape 2️⃣ : Déployer l'Application (5 min)

Double-cliquez sur :
```
deploy.bat
```

**Ce qui se passe** :
- ⏳ Construction des images Docker (2-3 min la 1ère fois)
- ⏳ Démarrage des 4 services (PostgreSQL, Redis, Backend, Frontend)
- ⏳ Tests de connectivité
- ✅ Ouverture automatique dans le navigateur

**Résultat attendu** :
- 4 conteneurs actifs dans Docker Desktop
- Frontend : http://localhost/
- Backend : http://localhost:8000/docs

---

## Étape 3️⃣ : Valider C21 (10 min)

Double-cliquez sur :
```
validate-c21.bat
```

**Ce qui se passe** :
- ✅ Tests de connectivité
- ✅ Tests unitaires
- ✅ Scan de sécurité
- ✅ Génération des rapports dans `reports/`

**Prendre des screenshots** :
1. Docker Desktop (onglet Containers)
2. http://localhost/ (frontend)
3. http://localhost:8000/docs (backend)
4. Terminal avec résultats des tests

---

## 🎯 C'est Tout !

**Vous avez maintenant** :
- ✅ Infrastructure déployée (C21.3)
- ✅ Services fonctionnels
- ✅ Tests validés (C21.5)
- ✅ Rapports de sécurité (C21.4)
- ✅ Screenshots pour le rapport

**Temps total** : 15-20 minutes

---

## 📸 Screenshots à Prendre

### 1. Docker Desktop
- Ouvrir Docker Desktop
- Onglet "Containers"
- Screenshot montrant les 4 conteneurs actifs :
  - `digitrans-postgres`
  - `digitrans-redis`
  - `digitrans-backend`
  - `digitrans-frontend`

### 2. Frontend
- Ouvrir http://localhost/
- Screenshot de la page d'accueil

### 3. Backend API
- Ouvrir http://localhost:8000/docs
- Screenshot de la documentation Swagger

### 4. Health Check
- Ouvrir http://localhost:8000/health
- Screenshot du JSON de réponse

### 5. Terminal
- Screenshot du résultat de `deploy.bat`
- Screenshot du résultat de `validate-c21.bat`

**Sauvegarder dans** : `docs/screenshots/`

---

## 🛠️ Commandes Utiles

### Voir les logs
```bash
docker-compose logs -f
```

### Arrêter les services
```bash
docker-compose down
```

### Redémarrer
```bash
docker-compose restart
```

### Accéder à un conteneur
```bash
# Backend
docker exec -it digitrans-backend bash

# PostgreSQL
docker exec -it digitrans-postgres psql -U admin -d crm_db

# Redis
docker exec -it digitrans-redis redis-cli
```

---

## ❓ Problèmes Fréquents

### "Docker n'est pas démarré"
**Solution** : Ouvrir Docker Desktop et attendre l'icône verte

### "Port 80 déjà utilisé"
**Solution** : Arrêter le service qui utilise le port 80 (IIS, Apache, etc.)
```bash
netstat -ano | findstr :80
```

### "Erreur de build"
**Solution** : Reconstruire sans cache
```bash
docker-compose build --no-cache
docker-compose up -d
```

### "Services ne démarrent pas"
**Solution** : Vérifier les logs
```bash
docker-compose logs
```

---

## ✅ Checklist Finale

- [ ] `check-prereqs.bat` → Tous ✅
- [ ] `deploy.bat` → Services démarrés
- [ ] http://localhost/ → Frontend accessible
- [ ] http://localhost:8000/docs → Backend accessible
- [ ] `validate-c21.bat` → Tests passent
- [ ] Screenshots capturés
- [ ] Rapports dans `reports/`

**Quand tout est coché : C21 VALIDÉ ! 🎉**

---

## 📝 Prochaines Étapes

1. Créer `docs/C21-validation-deploiement.md`
2. Insérer les screenshots
3. Copier les résultats des tests
4. Pousser sur GitHub :
   ```bash
   git add .
   git commit -m "feat: C21 validation with Docker deployment"
   git push origin main
   ```

---

**Prêt ?** Lancez `check-prereqs.bat` ! 🚀
