# Architecture Technique - Module CRM DIGITRANS-CM

## Vue d'Ensemble

Le module CRM est conçu selon une architecture cloud hybride multi-fournisseurs (AWS + Azure) pour répondre aux contraintes de souveraineté des données, de résilience et de performance dans le contexte camerounais.

## Schéma d'Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    UTILISATEURS FINAUX                       │
│         (Restaurants SavoirManger - Douala, Yaoundé)        │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              AZURE AD (Entra ID)                             │
│         • Authentification OAuth 2.0 / OpenID Connect        │
│         • Gestion des identités et accès (IAM)               │
│         • Multi-Factor Authentication (MFA)                  │
└──────────────────────┬──────────────────────────────────────┘
                       │ Token JWT
                       ▼
┌─────────────────────────────────────────────────────────────┐
│           FRONTEND - AWS S3 + CloudFront                     │
│         • Application Web statique (HTML/CSS/JS)             │
│         • CDN CloudFront (cache edge locations)              │
│         • Certificat SSL/TLS                                 │
│         • Fonctionnement offline-first (Service Worker)      │
└──────────────────────┬──────────────────────────────────────┘
                       │ REST API (HTTPS)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              API GATEWAY (AWS API Gateway)                   │
│         • Rate limiting                                      │
│         • Validation des requêtes                            │
│         • Logs et monitoring                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│           BACKEND API - AWS Lambda / EC2                     │
│         • Python (Flask/FastAPI)                             │
│         • Endpoints REST :                                   │
│           - /api/clients (CRUD)                              │
│           - /api/contacts (CRUD)                             │
│           - /api/interactions (CRUD)                         │
│         • Validation Azure AD Token                          │
│         • Cache Redis (ElastiCache)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│        BASE DE DONNÉES - AWS RDS PostgreSQL                  │
│         • Région : Afrique du Sud (af-south-1)               │
│         • Multi-AZ pour haute disponibilité                  │
│         • Chiffrement au repos (AES-256)                     │
│         • Backups automatiques quotidiens                    │
│         • Tables : clients, contacts, interactions           │
└─────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              MONITORING - Azure Monitor                      │
│         • Logs centralisés (Log Analytics)                   │
│         • Métriques de performance                           │
│         • Alertes automatiques                               │
│         • Dashboards temps réel                              │
└─────────────────────────────────────────────────────────────┘
```

## Composants Détaillés

### 1. Authentification (Azure AD)
- **Service** : Azure Active Directory (Entra ID)
- **Protocole** : OAuth 2.0 / OpenID Connect
- **Fonctionnalités** :
  - Single Sign-On (SSO)
  - Multi-Factor Authentication (MFA)
  - Gestion des rôles (RBAC) : Admin, Manager, Agent
  - Tokens JWT avec expiration 1h

### 2. Frontend (AWS S3 + CloudFront)
- **Hébergement** : S3 Bucket (site web statique)
- **CDN** : CloudFront avec edge locations africaines
- **Technologies** : HTML5, CSS3, JavaScript (Vanilla)
- **Template** : AdminLTE ou CoreUI (Bootstrap-based)
- **Fonctionnalités** :
  - Interface responsive (mobile-first)
  - Mode offline avec Service Worker
  - Cache local (LocalStorage/IndexedDB)
  - Synchronisation différée

### 3. API Backend (AWS Lambda ou EC2)
- **Langage** : Python 3.11+
- **Framework** : FastAPI (performance) ou Flask (simplicité)
- **Déploiement** : 
  - Option 1 : AWS Lambda + API Gateway (serverless)
  - Option 2 : EC2 t3.small (Afrique du Sud)
- **Endpoints** :
  ```
  POST   /api/auth/login          # Authentification
  GET    /api/clients             # Liste clients
  POST   /api/clients             # Créer client
  GET    /api/clients/{id}        # Détails client
  PUT    /api/clients/{id}        # Modifier client
  DELETE /api/clients/{id}        # Supprimer client
  GET    /api/clients/{id}/contacts
  POST   /api/contacts
  GET    /api/interactions
  POST   /api/interactions
  ```

### 4. Base de Données (AWS RDS PostgreSQL)
- **Version** : PostgreSQL 15
- **Instance** : db.t3.micro (dev) / db.t3.small (prod)
- **Région** : af-south-1 (Afrique du Sud)
- **Configuration** :
  - Multi-AZ : Oui
  - Backup retention : 7 jours
  - Chiffrement : AES-256
  - SSL/TLS obligatoire

**Schéma de données** :
```sql
-- Table clients
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    telephone VARCHAR(20),
    adresse TEXT,
    ville VARCHAR(100),
    statut VARCHAR(50) DEFAULT 'actif',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table contacts
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255),
    fonction VARCHAR(100),
    email VARCHAR(255),
    telephone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Table interactions
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- appel, email, visite, reunion
    sujet VARCHAR(255),
    description TEXT,
    date_interaction TIMESTAMP NOT NULL,
    user_id VARCHAR(255), -- ID Azure AD
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 5. Monitoring (Azure Monitor)
- **Logs** : Azure Log Analytics Workspace
- **Métriques** :
  - Temps de réponse API
  - Taux d'erreur
  - Nombre de requêtes/min
  - Utilisation CPU/RAM
- **Alertes** :
  - Temps de réponse > 2s
  - Taux d'erreur > 5%
  - Disponibilité < 99%

## Choix Techniques Justifiés

### Pourquoi AWS pour l'applicatif ?
- Région Afrique du Sud disponible (latence réduite)
- Services managés matures (RDS, S3, Lambda)
- Coûts optimisés pour petites charges

### Pourquoi Azure pour l'authentification ?
- Azure AD : solution enterprise de référence
- Intégration native avec Microsoft 365 (si AGROCAM l'utilise)
- Monitoring centralisé performant

### Pourquoi PostgreSQL ?
- Open source (pas de coûts de licence)
- Robuste et performant
- Support JSON pour flexibilité future
- Compatibilité avec AWS RDS

## Contraintes Respectées

✅ **Souveraineté** : Données en Afrique du Sud (AWS af-south-1)  
✅ **Résilience** : Multi-AZ, cache, mode offline  
✅ **Latence** : Région africaine, CDN, cache Redis  
✅ **Sécurité** : Chiffrement, Azure AD, HTTPS, RBAC  
✅ **Conformité** : Logs traçables, backups, audit trail  

## Évolutions Futures

- Migration vers Kubernetes (EKS) pour scalabilité
- Ajout de blockchain pour traçabilité (exigence projet)
- Intégration avec modules ERP/Supply Chain
- Analytics avancés avec AWS QuickSight
