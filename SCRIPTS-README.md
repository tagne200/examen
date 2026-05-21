# 📦 Scripts de Déploiement - DIGITRANS-CM CRM

## 🎯 Validation Compétence C21

Ce dossier contient tous les scripts nécessaires pour **déployer et valider** l'infrastructure du module CRM.

---

## 📋 Scripts Disponibles

### 1️⃣ `check-prereqs.bat` - Vérification des Prérequis
**Utilisation** : Double-cliquer ou `check-prereqs.bat`

**Fonction** :
- ✅ Vérifie que Docker est installé
- ✅ Vérifie que Docker est démarré
- ✅ Vérifie l'espace disque disponible
- ✅ Affiche un résumé des prérequis

**Quand l'utiliser** : Avant le premier déploiement

---

### 2️⃣ `deploy.bat` - Déploiement Complet
**Utilisation** : Double-cliquer ou `deploy.bat`

**Fonction** :
- 🏗️ Construit les images Docker
- 🚀 Démarre tous les services (PostgreSQL, Redis, Backend, Frontend)
- 🧪 Teste la connectivité
- 🌐 Ouvre l'application dans le navigateur

**Durée** : 3-5 minutes (première fois), 30 secondes (suivantes)

**Services déployés** :
- PostgreSQL (port 5432) - Simule AWS RDS
- Redis (port 6379) - Simule AWS ElastiCache
- Backend API (port 8000) - Simule AWS Lambda/EC2
- Frontend (port 80) - Simule AWS S3 + CloudFront

---

### 3️⃣ `validate-c21.bat` - Validation Technique
**Utilisation** : Double-cliquer ou `validate-c21.bat`

**Fonction** :
- ✅ Tests de connectivité (C21.5)
- ✅ Tests unitaires (C21.5)
- ✅ Tests de performance (C21.5)
- ✅ Scan de sécurité Bandit (C21.4)
- ✅ Audit dépendances Safety (C21.4)
- 📊 Génère les rapports dans `reports/`

**Durée** : 2-3 minutes

**Rapports générés** :
- `reports/test-frontend.txt`
- `reports/test-health.json`
- `reports/test-results.txt`
- `reports/security-bandit.txt`
- `reports/security-safety.txt`

---

### 4️⃣ `deploy-local.bat` - Version Alternative
**Utilisation** : `deploy-local.bat`

**Fonction** : Version détaillée de `deploy.bat` avec plus de logs

---

## 🚀 Démarrage Rapide (3 Étapes)

### Étape 1 : Vérifier
```bash
check-prereqs.bat
```
→ Tous les ✅ doivent être verts

### Étape 2 : Déployer
```bash
deploy.bat
```
→ Attendre l'ouverture du navigateur

### Étape 3 : Valider
```bash
validate-c21.bat
```
→ Vérifier que tous les tests passent

**C'est tout !** 🎉

---

## 📸 Preuves pour C21

### Screenshots à Capturer

1. **Docker Desktop** (C21.3)
   - Onglet Containers
   - 4 services actifs

2. **Frontend** (C21.3)
   - http://localhost/
   - Page d'accueil fonctionnelle

3. **Backend API** (C21.3)
   - http://localhost:8000/docs
   - Documentation Swagger

4. **Health Check** (C21.5)
   - http://localhost:8000/health
   - JSON de réponse

5. **Tests** (C21.5)
   - Terminal avec résultats de `validate-c21.bat`

6. **Sécurité** (C21.4)
   - Rapports Bandit et Safety

**Sauvegarder dans** : `docs/screenshots/`

---

## 🏗️ Architecture Déployée

```
┌─────────────────────────────────────────────────────┐
│                  DIGITRANS-CM CRM                   │
│              Architecture Docker Locale              │
└─────────────────────────────────────────────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend   │────▶│   Backend    │────▶│  PostgreSQL  │
│  (Nginx:80)  │     │ (FastAPI:8000)│     │   (5432)     │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │    Redis     │
                     │   (6379)     │
                     └──────────────┘

Réseau: digitrans-network (bridge)
Volumes: postgres_data (persistant)
```

---

## 🔗 URLs d'Accès

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost/ | Interface utilisateur |
| **Backend** | http://localhost:8000/ | API REST |
| **API Docs** | http://localhost:8000/docs | Documentation Swagger |
| **Health** | http://localhost:8000/health | Health check |
| **PostgreSQL** | localhost:5432 | Base de données |
| **Redis** | localhost:6379 | Cache |

---

## 🔐 Credentials

### PostgreSQL
```
Host:     localhost
Port:     5432
Database: crm_db
User:     admin
Password: SecurePassword123!
```

### Redis
```
Host: localhost
Port: 6379
```

---

## 🛠️ Commandes Docker Utiles

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

---

## 📊 Validation C21

| Critère | Script | Preuve |
|---------|--------|--------|
| **C21.1** | - | Documentation (50+ pages) |
| **C21.2** | - | Justifications services |
| **C21.3** | `deploy.bat` | Screenshots déploiement |
| **C21.4** | `validate-c21.bat` | Rapports sécurité |
| **C21.5** | `validate-c21.bat` | Rapports tests |

---

## 🐛 Dépannage

### Docker n'est pas démarré
```bash
# Ouvrir Docker Desktop
# Attendre l'icône verte
# Relancer deploy.bat
```

### Port 80 déjà utilisé
```bash
# Trouver le processus
netstat -ano | findstr :80

# Arrêter IIS (si installé)
iisreset /stop

# Ou changer le port dans docker-compose.yml
```

### Erreur de build
```bash
# Reconstruire sans cache
docker-compose build --no-cache
docker-compose up -d
```

### Services ne démarrent pas
```bash
# Voir les logs
docker-compose logs

# Redémarrer Docker Desktop
```

---

## 📚 Documentation Complète

- **Guide Rapide** : `DEMARRAGE-RAPIDE.md`
- **Guide Détaillé** : `GUIDE-DEPLOIEMENT-LOCAL.md`
- **Validation C21** : `C21-VALIDATION-RAPIDE.md`
- **Architecture** : `docs/C21-conception-architecture.md`
- **Mise en Œuvre** : `docs/C21-mise-en-oeuvre.md`

---

## ✅ Checklist Finale

- [ ] Docker Desktop installé et démarré
- [ ] `check-prereqs.bat` → Tous ✅
- [ ] `deploy.bat` → Services actifs
- [ ] http://localhost/ → Frontend OK
- [ ] http://localhost:8000/docs → Backend OK
- [ ] `validate-c21.bat` → Tests OK
- [ ] Screenshots capturés
- [ ] Rapports dans `reports/`
- [ ] Document de validation créé
- [ ] Poussé sur GitHub

**Quand tout est coché : C21 VALIDÉ ! 🎉**

---

## 🎓 Équivalences Cloud

| Docker Local | AWS Cloud | Validation |
|--------------|-----------|------------|
| postgres:15 | RDS PostgreSQL | ✅ Même SGBD |
| redis:7 | ElastiCache Redis | ✅ Même cache |
| nginx | S3 + CloudFront | ✅ Même hébergement |
| backend | Lambda/EC2 | ✅ Même API |
| docker network | VPC | ✅ Même isolation |

**Conclusion** : Le déploiement Docker local **valide pleinement** la compétence C21 !

---

**Prêt à déployer ?** Lancez `check-prereqs.bat` ! 🚀
