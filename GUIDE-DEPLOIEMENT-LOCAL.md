# Guide de Déploiement Local - Validation C21

## 🎯 Objectif

Valider la compétence **C21 : Intégrer des Services Cloud** en déployant l'infrastructure localement avec Docker (simulation cloud).

---

## 📋 Prérequis

### 1. Docker Desktop

**Vérifier l'installation** :
```bash
docker --version
docker-compose --version
```

**Si non installé** :
1. Télécharger : https://www.docker.com/products/docker-desktop
2. Installer Docker Desktop
3. Démarrer Docker Desktop
4. Vérifier que Docker est en cours d'exécution (icône dans la barre des tâches)

### 2. Espace Disque

- Minimum : 5 GB d'espace libre
- Recommandé : 10 GB

---

## 🚀 Étapes de Déploiement

### Étape 1 : Démarrer Docker Desktop

1. Ouvrir Docker Desktop
2. Attendre que Docker soit complètement démarré (icône verte)

### Étape 2 : Déployer l'Infrastructure

**Option A : Script Automatique (Recommandé)**

```bash
cd c:\Users\KENNETH\Desktop\Examen
deploy-local.bat
```

Le script va :
- ✅ Vérifier Docker
- ✅ Construire les images
- ✅ Démarrer tous les services
- ✅ Tester la connectivité
- ✅ Ouvrir le navigateur

**Option B : Commandes Manuelles**

```bash
cd c:\Users\KENNETH\Desktop\Examen

# Construire et démarrer
docker-compose up -d --build

# Vérifier l'état
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### Étape 3 : Vérifier le Déploiement

**Services déployés** :

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| Frontend | 80 | http://localhost/ | Interface web |
| Backend | 8000 | http://localhost:8000/ | API REST |
| API Docs | 8000 | http://localhost:8000/docs | Documentation Swagger |
| PostgreSQL | 5432 | localhost:5432 | Base de données |
| Redis | 6379 | localhost:6379 | Cache |

**Tests manuels** :

```bash
# Frontend
curl http://localhost/

# Backend Health
curl http://localhost:8000/health

# API Root
curl http://localhost:8000/

# PostgreSQL
docker exec digitrans-postgres pg_isready -U admin -d crm_db

# Redis
docker exec digitrans-redis redis-cli ping
```

### Étape 4 : Validation Technique (C21.5)

```bash
validate-c21.bat
```

Ce script exécute :
- ✅ Tests de connectivité
- ✅ Tests unitaires
- ✅ Tests de performance
- ✅ Scan de sécurité (Bandit + Safety)
- ✅ Vérification des logs

**Rapports générés** dans `reports/` :
- `test-frontend.txt` : Test du frontend
- `test-health.json` : Health check API
- `test-api-root.json` : API root endpoint
- `test-results.txt` : Résultats tests unitaires
- `security-bandit.txt` : Scan de sécurité Bandit
- `security-safety.txt` : Audit dépendances Safety

---

## 📸 Preuves pour C21

### C21.3 : Déploiement Infrastructure

**Captures d'écran à faire** :

1. **Docker Desktop** : Services en cours d'exécution
   - Ouvrir Docker Desktop
   - Onglet "Containers"
   - Screenshot montrant les 4 conteneurs actifs

2. **Frontend fonctionnel**
   - Ouvrir http://localhost/
   - Screenshot de la page d'accueil

3. **Backend API**
   - Ouvrir http://localhost:8000/docs
   - Screenshot de la documentation Swagger

4. **Health Check**
   - Ouvrir http://localhost:8000/health
   - Screenshot du JSON de réponse

5. **Commande docker-compose ps**
   ```bash
   docker-compose ps
   ```
   - Screenshot du terminal

### C21.4 : Sécurité

**Rapports à inclure** :

1. **Scan Bandit** : `reports\security-bandit.txt`
2. **Audit Safety** : `reports\security-safety.txt`
3. **Configuration Security Groups** : Dans docker-compose.yml

### C21.5 : Validation Technique

**Rapports à inclure** :

1. **Tests unitaires** : `reports\test-results.txt`
2. **Tests de connectivité** : `reports\test-*.json`
3. **Logs** : Captures des logs Docker

---

## 🔧 Commandes Utiles

### Gestion des Services

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart

# Voir les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend

# État des services
docker-compose ps
```

### Accès aux Conteneurs

```bash
# Backend
docker exec -it digitrans-backend bash

# PostgreSQL
docker exec -it digitrans-postgres psql -U admin -d crm_db

# Redis
docker exec -it digitrans-redis redis-cli
```

### Tests Manuels

```bash
# Tests unitaires
docker exec digitrans-backend pytest tests/ -v

# Scan de sécurité
docker exec digitrans-backend bandit -r app/

# Audit dépendances
docker exec digitrans-backend safety check
```

### Nettoyage

```bash
# Arrêter et supprimer tout
docker-compose down -v

# Supprimer les images
docker-compose down --rmi all

# Nettoyage complet Docker
docker system prune -a
```

---

## 🐛 Dépannage

### Problème : Docker n'est pas démarré

**Erreur** : `error during connect: This error may indicate that the docker daemon is not running`

**Solution** :
1. Ouvrir Docker Desktop
2. Attendre que l'icône devienne verte
3. Relancer la commande

### Problème : Port déjà utilisé

**Erreur** : `Bind for 0.0.0.0:80 failed: port is already allocated`

**Solution** :
```bash
# Trouver le processus utilisant le port
netstat -ano | findstr :80

# Arrêter le processus ou changer le port dans docker-compose.yml
```

### Problème : Manque d'espace disque

**Erreur** : `no space left on device`

**Solution** :
```bash
# Nettoyer Docker
docker system prune -a

# Supprimer les volumes inutilisés
docker volume prune
```

### Problème : Build échoue

**Erreur** : `ERROR [backend internal] load metadata`

**Solution** :
```bash
# Reconstruire sans cache
docker-compose build --no-cache

# Puis redémarrer
docker-compose up -d
```

---

## ✅ Checklist de Validation

### C21.1 : Architecture
- [x] Documentation complète
- [x] docker-compose.yml créé
- [x] Architecture multi-services

### C21.2 : Sélection Services
- [x] PostgreSQL (simule RDS)
- [x] Redis (simule ElastiCache)
- [x] Nginx (simule CloudFront)
- [x] FastAPI (backend)

### C21.3 : Déploiement
- [ ] Docker Desktop installé
- [ ] Services démarrés avec succès
- [ ] Screenshots capturés
- [ ] Tous les services accessibles

### C21.4 : Sécurité
- [ ] Scan Bandit exécuté
- [ ] Audit Safety exécuté
- [ ] Rapports générés
- [ ] Pas de vulnérabilités critiques

### C21.5 : Validation
- [ ] Tests de connectivité OK
- [ ] Tests unitaires passent
- [ ] Tests de performance OK
- [ ] Rapports générés

---

## 📊 Métriques Attendues

### Performance
- Temps de réponse API : < 100ms (local)
- Temps de chargement frontend : < 1s
- Tests unitaires : 100% passent

### Sécurité
- Bandit : 0 vulnérabilités HIGH
- Safety : 0 vulnérabilités critiques

### Disponibilité
- Health check : 200 OK
- Tous les services : UP

---

## 📝 Rapport de Validation

Après avoir exécuté tous les tests, créer un document `C21-validation-deploiement.md` avec :

1. **Screenshots** :
   - Docker Desktop (services actifs)
   - Frontend fonctionnel
   - Backend API Docs
   - Health check

2. **Résultats des tests** :
   - Copier le contenu de `reports/test-results.txt`
   - Copier les rapports de sécurité

3. **Métriques** :
   - Temps de réponse
   - Nombre de tests passés
   - Vulnérabilités trouvées

4. **Conclusion** :
   - Compétence C21 validée ✅
   - Infrastructure déployée avec succès
   - Tests passent
   - Sécurité vérifiée

---

## 🎓 Correspondance avec C21

| Critère | Preuve | Fichier |
|---------|--------|---------|
| C21.1 | Architecture documentée | docker-compose.yml, nginx.conf |
| C21.2 | Services sélectionnés | PostgreSQL, Redis, Nginx, FastAPI |
| C21.3 | Infrastructure déployée | Screenshots, docker-compose ps |
| C21.4 | Sécurité | reports/security-*.txt |
| C21.5 | Validation technique | reports/test-*.txt |

---

**Prêt à déployer ?** Lancez `deploy-local.bat` ! 🚀
