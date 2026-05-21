# C21 - Conception et Intégration de l'Architecture Cloud

## Compétence Évaluée
**C21 : Intégrer des services cloud dans une architecture applicative**

---

## 1. ANALYSE DES BESOINS ET CONTRAINTES

### 1.1 Besoins Fonctionnels

**Module CRM pour AGROCAM S.A.**
- Gestion de 500+ clients (restaurants SavoirManger)
- Historique de 10 000+ interactions/an
- 50 utilisateurs simultanés (agents commerciaux)
- Disponibilité 24/7 (restaurants ouverts tous les jours)
- Temps de réponse < 2 secondes

### 1.2 Contraintes Techniques Camerounaises

| Contrainte | Impact | Solution Proposée |
|------------|--------|-------------------|
| **Coupures électriques** | 6-12h/jour à Douala | Mode offline, cache local, backups |
| **Latence réseau** | 150-250ms vers Europe/USA | Région africaine (af-south-1) |
| **Connectivité limitée** | Débits variables | Optimisation requêtes, CDN |
| **Souveraineté données** | Hébergement local obligatoire | RDS en Afrique du Sud |
| **Budget limité** | 480M FCFA (800K€) | Services managés, serverless |

### 1.3 Contraintes Réglementaires

**Loi camerounaise n°2010/012**
- ✅ Données sensibles hébergées en Afrique
- ✅ Traçabilité des accès obligatoire
- ✅ Chiffrement des données
- ✅ Conformité RGPD (clients européens potentiels)

---

## 2. CHOIX DE L'ARCHITECTURE CLOUD

### 2.1 Stratégie Multi-Cloud Hybride

**Décision : AWS + Azure**

#### Pourquoi AWS ?
✅ **Région Afrique du Sud** (af-south-1) disponible
✅ **Services managés matures** : RDS, S3, Lambda, CloudFront
✅ **Coûts optimisés** pour petites charges
✅ **Latence réduite** : ~80ms depuis Douala
✅ **Écosystème riche** : 200+ services

#### Pourquoi Azure ?
✅ **Azure AD** : Standard enterprise pour l'authentification
✅ **Intégration Microsoft 365** (si AGROCAM l'utilise)
✅ **Azure Monitor** : Monitoring centralisé performant
✅ **Présence en Afrique** : Région Afrique du Sud

#### Pourquoi PAS Google Cloud ?
❌ Pas de région africaine (la plus proche : Europe)
❌ Moins de services managés en Afrique
❌ Coûts plus élevés pour notre use case

### 2.2 Architecture Détaillée

```
┌─────────────────────────────────────────────────────────────────┐
│                    UTILISATEURS FINAUX                           │
│         (50 agents commerciaux - Douala, Yaoundé, etc.)         │
└──────────────────────┬──────────────────────────────────────────┘
                       │ HTTPS (TLS 1.3)
                       │
┌──────────────────────▼──────────────────────────────────────────┐
│                    AZURE AD (Entra ID)                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ • OAuth 2.0 / OpenID Connect                               │ │
│  │ • Multi-Factor Authentication (MFA)                        │ │
│  │ • Conditional Access Policies                              │ │
│  │ • RBAC : Admin, Manager, Agent                             │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                       │ JWT Token (1h expiration)
                       │
┌──────────────────────▼──────────────────────────────────────────┐
│              AWS CLOUDFRONT (CDN)                                │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ • Edge Locations : Afrique du Sud, Europe                  │ │
│  │ • Cache TTL : 1 heure (statique), 5 min (dynamique)        │ │
│  │ • Compression Gzip/Brotli                                  │ │
│  │ • SSL/TLS Certificate (ACM)                                │ │
│  │ • WAF : Protection DDoS, SQL Injection                     │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌───────────────────┐         ┌───────────────────┐
│   FRONTEND (S3)   │         │  API GATEWAY      │
│                   │         │                   │
│ • Static Website  │         │ • Rate Limiting   │
│ • HTML/CSS/JS     │         │   100 req/min     │
│ • Versioning      │         │ • Request         │
│ • Lifecycle       │         │   Validation      │
│   Policies        │         │ • CORS Config     │
└───────────────────┘         └─────────┬─────────┘
                                        │
                              ┌─────────▼─────────┐
                              │                   │
                    ┌─────────┴─────────┐         │
                    │                   │         │
                    ▼                   ▼         ▼
            ┌───────────────┐   ┌───────────────┐
            │ AWS LAMBDA    │   │   EC2 (ALB)   │
            │               │   │               │
            │ • Python 3.11 │   │ • t3.small    │
            │ • FastAPI     │   │ • Auto Scaling│
            │ • Serverless  │   │ • 2 AZ        │
            │ • Cold Start  │   │ • Health Check│
            │   < 1s        │   │               │
            └───────┬───────┘   └───────┬───────┘
                    │                   │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │ ELASTICACHE REDIS │
                    │                   │
                    │ • Cache Layer     │
                    │ • Session Store   │
                    │ • TTL : 15 min    │
                    │ • cache.t3.micro  │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │  AWS RDS          │
                    │  PostgreSQL 15    │
                    │                   │
                    │ • db.t3.small     │
                    │ • Multi-AZ        │
                    │ • 20 GB SSD       │
                    │ • Automated       │
                    │   Backups (7j)    │
                    │ • Encryption      │
                    │   AES-256         │
                    │ • Region:         │
                    │   af-south-1      │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │  AWS S3 (Backups) │
                    │                   │
                    │ • Versioning      │
                    │ • Lifecycle       │
                    │ • Glacier (30j)   │
                    └───────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    AZURE MONITOR                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ • Log Analytics Workspace                                  │ │
│  │ • Application Insights                                     │ │
│  │ • Alertes : Email, SMS, Webhook                            │ │
│  │ • Dashboards temps réel                                    │ │
│  │ • Rétention : 90 jours                                     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. JUSTIFICATION DES CHOIX TECHNIQUES

### 3.1 Services AWS Sélectionnés

#### AWS RDS PostgreSQL
**Choix** : Base de données managée PostgreSQL 15

**Justifications** :
- ✅ **Open source** : Pas de coûts de licence
- ✅ **Robustesse** : ACID, transactions, intégrité référentielle
- ✅ **Performance** : Support JSON, indexes avancés
- ✅ **Multi-AZ** : Haute disponibilité (99.95%)
- ✅ **Backups automatiques** : Point-in-time recovery
- ✅ **Chiffrement** : AES-256 au repos, SSL/TLS en transit
- ✅ **Région africaine** : af-south-1 (Cape Town)

**Alternatives considérées** :
- ❌ MySQL : Moins de fonctionnalités avancées
- ❌ DynamoDB : NoSQL, moins adapté aux relations complexes
- ❌ Aurora : Coûts 2-3x plus élevés

**Configuration** :
```yaml
Instance: db.t3.small (2 vCPU, 2 GB RAM)
Storage: 20 GB SSD (gp3)
Multi-AZ: Oui (failover automatique)
Backup: 7 jours de rétention
Maintenance: Dimanche 02:00-04:00 UTC
```

#### AWS S3 + CloudFront
**Choix** : Hébergement statique + CDN

**Justifications** :
- ✅ **Coût** : ~0.023 USD/GB/mois
- ✅ **Scalabilité** : Illimitée
- ✅ **Disponibilité** : 99.99%
- ✅ **CDN** : Edge locations en Afrique
- ✅ **HTTPS** : Certificat SSL gratuit (ACM)
- ✅ **Versioning** : Rollback facile

**Configuration** :
```yaml
Bucket: digitrans-crm-frontend
Region: af-south-1
Versioning: Enabled
Encryption: AES-256
Public Access: Via CloudFront uniquement
Lifecycle: Delete old versions after 30 days
```

#### AWS Lambda vs EC2
**Choix** : Lambda pour démarrer, EC2 si besoin

**Lambda (Recommandé pour Phase 1)** :
- ✅ **Serverless** : Pas de gestion de serveurs
- ✅ **Auto-scaling** : Automatique
- ✅ **Coût** : Pay-per-use (1M requêtes gratuites/mois)
- ✅ **Cold start** : < 1s avec Python
- ❌ **Limite** : 15 min timeout, 10 GB RAM max

**EC2 (Si charge > 1000 req/min)** :
- ✅ **Contrôle total** : Configuration personnalisée
- ✅ **Pas de cold start** : Toujours chaud
- ✅ **Pas de timeout** : Requêtes longues possibles
- ❌ **Gestion** : Patches, monitoring, scaling manuel

**Décision** : Commencer avec Lambda, migrer vers EC2 si nécessaire.

#### ElastiCache Redis
**Choix** : Cache distribué

**Justifications** :
- ✅ **Performance** : Réponses < 1ms
- ✅ **Réduction charge DB** : 60-80% de requêtes en cache
- ✅ **Session store** : Tokens, sessions utilisateurs
- ✅ **TTL flexible** : Expiration automatique

**Configuration** :
```yaml
Instance: cache.t3.micro (0.5 GB RAM)
Engine: Redis 7.0
Cluster: Single node (dev), Multi-AZ (prod)
Eviction: allkeys-lru
```

### 3.2 Services Azure Sélectionnés

#### Azure Active Directory (Entra ID)
**Choix** : Authentification centralisée

**Justifications** :
- ✅ **Standard enterprise** : OAuth 2.0, OpenID Connect
- ✅ **MFA natif** : Sécurité renforcée
- ✅ **RBAC** : Gestion fine des permissions
- ✅ **Conditional Access** : Politiques basées sur le contexte
- ✅ **Intégration Microsoft 365** : Si AGROCAM l'utilise
- ✅ **Audit logs** : Traçabilité complète

**Configuration** :
```yaml
Tenant: agrocam.onmicrosoft.com
App Registration: DIGITRANS-CRM
Redirect URIs: 
  - https://crm.agrocam.cm/callback
  - http://localhost:3000/callback (dev)
Token Lifetime: 1 heure
Refresh Token: 90 jours
Roles: Admin, Manager, Agent
```

#### Azure Monitor
**Choix** : Monitoring centralisé

**Justifications** :
- ✅ **Logs centralisés** : AWS + Azure + On-premise
- ✅ **Requêtes KQL** : Langage puissant
- ✅ **Alertes** : Email, SMS, Webhook, Logic Apps
- ✅ **Dashboards** : Visualisation temps réel
- ✅ **Intégration** : Application Insights, Log Analytics

**Configuration** :
```yaml
Workspace: digitrans-crm-logs
Region: South Africa North
Retention: 90 jours
Daily Cap: 1 GB (alertes si dépassé)
Alertes:
  - API errors > 5%
  - Response time > 2s
  - CPU > 80%
```

---

## 4. DIMENSIONNEMENT ET COÛTS

### 4.1 Calcul de Charge

**Hypothèses** :
- 50 utilisateurs simultanés
- 500 clients actifs
- 10 000 interactions/an (~30/jour)
- 100 requêtes API/utilisateur/jour
- Pics : 10h-12h et 14h-17h

**Charge estimée** :
```
Requêtes/jour : 50 users × 100 req = 5 000 req/jour
Requêtes/mois : 5 000 × 30 = 150 000 req/mois
Requêtes/seconde (pic) : 5 000 / (8h × 3600s) × 3 = ~0.5 req/s
Stockage DB : 500 clients × 10 KB = 5 MB (négligeable)
Stockage total (avec historique) : ~500 MB
```

### 4.2 Estimation des Coûts (USD/mois)

#### AWS Services

| Service | Configuration | Coût/mois |
|---------|---------------|-----------|
| **RDS PostgreSQL** | db.t3.small, 20 GB, Multi-AZ | $40 |
| **S3** | 10 GB stockage, 100 GB transfert | $3 |
| **CloudFront** | 100 GB transfert, 1M requêtes | $10 |
| **Lambda** | 150K invocations, 512 MB, 1s avg | $5 |
| **ElastiCache** | cache.t3.micro | $15 |
| **Route 53** | 1 hosted zone | $0.50 |
| **ACM** | Certificat SSL | Gratuit |
| **CloudWatch** | Logs, métriques | $5 |
| **Backups** | S3 Glacier, 50 GB | $2 |

**Total AWS** : ~$80/mois

#### Azure Services

| Service | Configuration | Coût/mois |
|---------|---------------|-----------|
| **Azure AD** | Free tier (50K objets) | Gratuit |
| **Azure Monitor** | 1 GB logs/jour | $10 |

**Total Azure** : ~$10/mois

#### **TOTAL MENSUEL : ~$90 USD (~54 000 FCFA)**

#### Coûts Annuels
- **Développement** : $90 × 12 = $1 080 (~650 000 FCFA)
- **Production** : $90 × 12 × 1.5 (marge) = $1 620 (~970 000 FCFA)

**Budget projet** : 480M FCFA
**Coûts cloud (18 mois)** : ~1.5M FCFA (0.3% du budget) ✅

### 4.3 Optimisations de Coûts

**Réservations** :
- RDS Reserved Instance (1 an) : -30% → $28/mois
- ElastiCache Reserved (1 an) : -30% → $10.50/mois

**Savings Plans** :
- Compute Savings Plan : -15% sur Lambda/EC2

**Lifecycle Policies** :
- S3 : Transition vers Glacier après 30 jours
- CloudWatch Logs : Rétention 30 jours (au lieu de 90)

**Coût optimisé** : ~$65/mois (~39 000 FCFA)

---

## 5. SÉCURITÉ ET CONFORMITÉ

### 5.1 Modèle de Sécurité

#### Principe de Défense en Profondeur

```
┌─────────────────────────────────────────┐
│ Couche 1 : Réseau                       │
│ • VPC isolé                             │
│ • Security Groups restrictifs           │
│ • NACLs                                 │
│ • WAF (CloudFront)                      │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│ Couche 2 : Authentification            │
│ • Azure AD OAuth 2.0                    │
│ • MFA obligatoire                       │
│ • Conditional Access                    │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│ Couche 3 : Autorisation                │
│ • RBAC (Admin, Manager, Agent)          │
│ • IAM Policies (AWS)                    │
│ • Least Privilege                       │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│ Couche 4 : Chiffrement                 │
│ • TLS 1.3 en transit                    │
│ • AES-256 au repos                      │
│ • KMS pour clés                         │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│ Couche 5 : Monitoring                  │
│ • CloudTrail (audit AWS)                │
│ • Azure AD logs                         │
│ • Azure Monitor                         │
│ • Alertes temps réel                    │
└─────────────────────────────────────────┘
```

### 5.2 Conformité Réglementaire

#### Loi Camerounaise n°2010/012

| Exigence | Solution | Statut |
|----------|----------|--------|
| Hébergement local | RDS en Afrique du Sud | ✅ |
| Traçabilité | CloudTrail + Azure AD logs | ✅ |
| Chiffrement | TLS + AES-256 | ✅ |
| Protection données | RBAC + MFA | ✅ |
| Notification incidents | Alertes Azure Monitor | ✅ |

#### RGPD (si applicable)

| Principe | Solution | Statut |
|----------|----------|--------|
| Consentement | Formulaire explicite | ✅ |
| Droit d'accès | API endpoint `/me` | ✅ |
| Droit à l'oubli | Soft delete + purge | ✅ |
| Portabilité | Export JSON/CSV | ✅ |
| Minimisation | Collecte stricte | ✅ |

---

## 6. RÉSILIENCE ET HAUTE DISPONIBILITÉ

### 6.1 Architecture Multi-AZ

```
Region: af-south-1 (Cape Town)

┌─────────────────────────────────────────┐
│ Availability Zone A                     │
│                                         │
│ • RDS Primary                           │
│ • Lambda (auto-distributed)             │
│ • ElastiCache Primary                   │
└─────────────────────────────────────────┘
           ↕ Synchronous Replication
┌─────────────────────────────────────────┐
│ Availability Zone B                     │
│                                         │
│ • RDS Standby (failover < 60s)          │
│ • Lambda (auto-distributed)             │
│ • ElastiCache Replica                   │
└─────────────────────────────────────────┘
```

### 6.2 Stratégie de Backup

#### RDS PostgreSQL
```yaml
Automated Backups:
  Retention: 7 jours
  Window: 02:00-04:00 UTC (04:00-06:00 Douala)
  Point-in-Time Recovery: Oui

Manual Snapshots:
  Frequency: Hebdomadaire (dimanche)
  Retention: 30 jours
  Cross-Region Copy: Non (coûts)
```

#### S3 Versioning
```yaml
Versioning: Enabled
Lifecycle:
  - Current version: Keep
  - Previous versions: Delete after 30 days
  - Deleted markers: Remove after 90 days
```

### 6.3 Plan de Reprise d'Activité (PRA)

| Scénario | RTO | RPO | Solution |
|----------|-----|-----|----------|
| Panne AZ | 60s | 0 | Multi-AZ automatique |
| Panne région | 4h | 1h | Backup cross-region (manuel) |
| Corruption données | 2h | 1h | Point-in-time recovery |
| Erreur humaine | 30min | 0 | S3 versioning |

**RTO** : Recovery Time Objective (temps de restauration)  
**RPO** : Recovery Point Objective (perte de données max)

---

## 7. PERFORMANCE ET OPTIMISATION

### 7.1 Objectifs de Performance

| Métrique | Objectif | Mesure |
|----------|----------|--------|
| Temps de réponse API | < 500ms | P95 |
| Temps de chargement page | < 2s | First Contentful Paint |
| Disponibilité | 99.5% | Uptime mensuel |
| Taux d'erreur | < 1% | Erreurs 5xx |

### 7.2 Stratégies d'Optimisation

#### Cache Multi-Niveaux

```
Browser Cache (1h)
    ↓
CloudFront Cache (1h)
    ↓
ElastiCache Redis (15min)
    ↓
RDS PostgreSQL
```

#### Optimisation Base de Données

```sql
-- Indexes stratégiques
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_clients_ville ON clients(ville);
CREATE INDEX idx_interactions_date ON interactions(date_interaction DESC);
CREATE INDEX idx_interactions_client ON interactions(client_id);

-- Requêtes optimisées
-- Utilisation de EXPLAIN ANALYZE
-- Pagination avec LIMIT/OFFSET
-- Eager loading des relations (SQLAlchemy)
```

#### Compression

```yaml
CloudFront:
  Gzip: Enabled
  Brotli: Enabled
  Compress: text/html, text/css, application/javascript, application/json

API:
  Response Compression: Enabled (FastAPI middleware)
```

---

## 8. VALIDATION TECHNIQUE

### 8.1 Tests de Charge

**Outil** : Locust ou k6

**Scénario** :
```python
# 50 utilisateurs simultanés
# Durée : 10 minutes
# Rampe : 1 minute

Endpoints testés:
- GET /api/clients (70%)
- POST /api/clients (10%)
- GET /api/interactions (15%)
- POST /api/interactions (5%)
```

**Résultats attendus** :
- Temps de réponse P95 < 500ms
- Taux d'erreur < 1%
- Throughput > 100 req/s

### 8.2 Tests de Sécurité

**Outils** :
- OWASP ZAP : Scan de vulnérabilités
- Bandit : Analyse statique Python
- Safety : Vérification dépendances
- AWS Trusted Advisor : Recommandations AWS

**Checklist** :
- [ ] Injection SQL
- [ ] XSS
- [ ] CSRF
- [ ] Broken Authentication
- [ ] Sensitive Data Exposure
- [ ] Security Misconfiguration

### 8.3 Tests de Résilience

**Chaos Engineering** :
```bash
# Simuler panne AZ
aws rds failover-db-cluster --db-cluster-identifier digitrans-crm

# Simuler charge élevée
locust -f loadtest.py --users 200 --spawn-rate 10

# Simuler latence réseau
tc qdisc add dev eth0 root netem delay 200ms
```

---

## 9. PLAN DE DÉPLOIEMENT

### 9.1 Phases de Déploiement

#### Phase 1 : Infrastructure (Jour 1)
- [ ] Créer VPC et subnets
- [ ] Créer RDS PostgreSQL
- [ ] Créer S3 bucket
- [ ] Configurer CloudFront
- [ ] Configurer Azure AD

#### Phase 2 : Application (Jour 2)
- [ ] Déployer backend (Lambda ou EC2)
- [ ] Déployer frontend (S3)
- [ ] Configurer API Gateway
- [ ] Tester end-to-end

#### Phase 3 : Monitoring (Jour 3)
- [ ] Configurer Azure Monitor
- [ ] Créer dashboards
- [ ] Configurer alertes
- [ ] Tests de charge

### 9.2 Rollback Plan

En cas de problème :
```bash
# Rollback frontend
aws s3 sync s3://digitrans-crm-frontend-backup/ s3://digitrans-crm-frontend/

# Rollback backend (Lambda)
aws lambda update-function-code --function-name digitrans-crm-api --s3-bucket backup-bucket --s3-key previous-version.zip

# Rollback base de données
aws rds restore-db-instance-to-point-in-time --source-db-instance-identifier digitrans-crm-db --target-db-instance-identifier digitrans-crm-db-restored --restore-time 2025-01-20T10:00:00Z
```

---

## 10. CONCLUSION

### 10.1 Synthèse des Choix

| Aspect | Solution | Justification |
|--------|----------|---------------|
| **Architecture** | Hybride AWS + Azure | Meilleur des deux mondes |
| **Base de données** | RDS PostgreSQL | Robuste, managé, africain |
| **Frontend** | S3 + CloudFront | Scalable, performant, économique |
| **Backend** | Lambda (puis EC2) | Serverless, auto-scaling |
| **Authentification** | Azure AD | Standard enterprise |
| **Monitoring** | Azure Monitor | Centralisé, puissant |
| **Région** | af-south-1 | Latence optimisée, conformité |

### 10.2 Avantages de l'Architecture

✅ **Performance** : Latence < 100ms depuis Douala  
✅ **Scalabilité** : Auto-scaling automatique  
✅ **Résilience** : Multi-AZ, backups automatiques  
✅ **Sécurité** : Chiffrement, MFA, RBAC  
✅ **Conformité** : Loi camerounaise, RGPD  
✅ **Coûts** : ~$90/mois (optimisable à $65)  
✅ **Maintenabilité** : Services managés, peu d'ops  

### 10.3 Limitations et Évolutions

**Limitations actuelles** :
- Mode offline partiel (à finaliser)
- Pas de multi-région (coûts)
- Cache basique (à enrichir)

**Évolutions futures** :
- Migration Kubernetes (EKS) pour plus de contrôle
- Multi-région (Cameroun + Afrique du Sud)
- Blockchain pour traçabilité
- IA/ML pour analytics

---

**Document validé par** : [Votre Nom]  
**Date** : Janvier 2025  
**Version** : 1.0  
**Statut** : Approuvé pour implémentation
