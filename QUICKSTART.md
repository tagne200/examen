# 🚀 Guide de Démarrage Rapide - DIGITRANS-CM CRM

## Prérequis

- ✅ Python 3.11+ installé
- ✅ Compte AWS avec accès région af-south-1
- ✅ Compte Azure avec Azure AD
- ✅ Git installé

---

## Démarrage en 5 Minutes (Mode Développement Local)

### Étape 1 : Cloner le Projet
```bash
git clone <votre-repo-url>
cd examen
```

### Étape 2 : Configuration Backend

#### Windows
```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

#### Linux/Mac
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Étape 3 : Configuration Base de Données

**Option A : PostgreSQL Local (Développement)**
```bash
# Installer PostgreSQL
# Créer une base de données
createdb crm_db

# Configurer .env
copy .env.example .env
# Éditer .env avec :
DATABASE_URL=postgresql://postgres:password@localhost:5432/crm_db
```

**Option B : AWS RDS (Production)**
Voir [DEPLOYMENT.md](DEPLOYMENT.md) pour les instructions complètes.

### Étape 4 : Initialiser la Base de Données
```bash
python -m app.database init
```

### Étape 5 : Démarrer l'API
```bash
python -m uvicorn app.main:app --reload --port 8000
```

✅ API disponible sur : http://localhost:8000  
✅ Documentation : http://localhost:8000/docs

### Étape 6 : Démarrer le Frontend

**Nouvelle fenêtre de terminal**
```bash
cd frontend
python -m http.server 3000
```

✅ Application disponible sur : http://localhost:3000

---

## Test Rapide

### 1. Vérifier l'API
```bash
curl http://localhost:8000/health
```

Réponse attendue :
```json
{
  "status": "healthy",
  "service": "DIGITRANS-CM CRM API",
  "version": "1.0.0"
}
```

### 2. Créer un Client de Test
```bash
curl -X POST "http://localhost:8000/api/clients" \
  -H "Authorization: Bearer dev-token" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Restaurant Test",
    "email": "test@example.cm",
    "ville": "Douala",
    "statut": "actif"
  }'
```

### 3. Accéder à l'Interface Web
Ouvrir http://localhost:3000 dans votre navigateur.

En mode développement, l'authentification est automatique (pas besoin d'Azure AD).

---

## Déploiement Production

### Checklist Avant Déploiement

- [ ] Comptes AWS et Azure configurés
- [ ] Base de données RDS créée
- [ ] Azure AD App Registration configurée
- [ ] Variables d'environnement définies
- [ ] Tests fonctionnels passés

### Déploiement Rapide

```bash
# 1. Déployer l'infrastructure (voir DEPLOYMENT.md)
# 2. Déployer le backend sur AWS Lambda ou EC2
# 3. Déployer le frontend sur S3 + CloudFront
# 4. Configurer Azure Monitor

# Voir DEPLOYMENT.md pour les commandes détaillées
```

---

## Structure du Projet

```
examen/
├── backend/              # API REST Python
│   ├── app/             # Code source
│   ├── requirements.txt # Dépendances
│   └── Dockerfile       # Conteneurisation
│
├── frontend/            # Application Web
│   ├── index.html      # Page principale
│   ├── config.js       # Configuration
│   └── assets/         # CSS, JS, images
│
├── infrastructure/      # Infrastructure as Code
│   ├── aws/            # Terraform AWS
│   └── azure/          # Terraform Azure
│
├── docs/               # Documentation
│   └── api-documentation.md
│
├── scripts/            # Scripts utilitaires
│   └── start.bat      # Démarrage rapide Windows
│
├── README.md           # Ce fichier
├── ARCHITECTURE.md     # Architecture technique
├── DEPLOYMENT.md       # Guide de déploiement
└── RAPPORT_ACTIVITE.md # Rapport d'activité
```

---

## Commandes Utiles

### Backend

```bash
# Démarrer le serveur
python -m uvicorn app.main:app --reload

# Initialiser la base de données
python -m app.database init

# Supprimer toutes les tables (ATTENTION)
python -m app.database drop

# Lancer les tests
pytest

# Créer un package de déploiement
pip install -r requirements.txt -t package/
```

### Frontend

```bash
# Serveur de développement
python -m http.server 3000

# Déployer sur S3
aws s3 sync . s3://digitrans-crm-frontend/ --region af-south-1
```

### Docker

```bash
# Construire l'image
docker build -t digitrans-crm-api ./backend

# Lancer le conteneur
docker run -p 8000:8000 --env-file backend/.env digitrans-crm-api
```

---

## Dépannage

### Problème : "Module not found"
```bash
# Réinstaller les dépendances
pip install -r requirements.txt --force-reinstall
```

### Problème : "Connection refused" à la base de données
```bash
# Vérifier que PostgreSQL est démarré
# Vérifier DATABASE_URL dans .env
# Tester la connexion :
psql $DATABASE_URL -c "SELECT 1;"
```

### Problème : CORS Error dans le navigateur
```bash
# Vérifier ALLOWED_ORIGINS dans backend/.env
# Doit inclure http://localhost:3000
```

### Problème : "Token invalid" en production
```bash
# Vérifier AZURE_TENANT_ID et AZURE_CLIENT_ID
# Vérifier que l'App Registration Azure AD est correcte
# Vérifier les redirect URIs
```

---

## Ressources

- **Documentation API** : http://localhost:8000/docs
- **Architecture** : [ARCHITECTURE.md](ARCHITECTURE.md)
- **Déploiement** : [DEPLOYMENT.md](DEPLOYMENT.md)
- **Rapport** : [RAPPORT_ACTIVITE.md](RAPPORT_ACTIVITE.md)

---

## Support

**CAMTECH SOLUTIONS S.A.**  
Email : support@camtech.cm  
Téléphone : +237 XXX XXX XXX

---

## Licence

© 2025 CAMTECH SOLUTIONS S.A. - Tous droits réservés.  
Projet DIGITRANS-CM pour AGROCAM S.A.
