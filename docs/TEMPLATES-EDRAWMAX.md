# Templates Texte pour EdrawMax

## 📋 Copier-Coller ces Textes dans EdrawMax

---

## SCHÉMA 1 : Architecture Globale

### Titre Principal
```
DIGITRANS-CM - Architecture Cloud Hybride
Module CRM AGROCAM S.A.
```

### Éléments

**Utilisateurs** :
```
50 Agents Commerciaux
Douala, Yaoundé, Cameroun
```

**Azure AD** :
```
Azure Active Directory (Entra ID)
Region: South Africa North

• OAuth 2.0 / OpenID Connect
• Multi-Factor Authentication (MFA)
• RBAC: Admin, Manager, Agent
• Token Lifetime: 1 heure
```

**CloudFront** :
```
AWS CloudFront (CDN)

• Edge Locations: Afrique, Europe
• Cache TTL: 1h (statique), 5min (dynamique)
• SSL/TLS Certificate (ACM)
• WAF: Protection DDoS, SQL Injection
```

**Frontend S3** :
```
Frontend (AWS S3)

• Static Website Hosting
• HTML/CSS/JavaScript
• Versioning Enabled
• Encryption: AES-256
```

**Backend Lambda** :
```
Backend API (AWS Lambda)

• Runtime: Python 3.11
• Framework: FastAPI
• Memory: 512 MB
• Timeout: 30s
• Auto-scaling
```

**PostgreSQL RDS** :
```
PostgreSQL 15 (AWS RDS)

• Instance: db.t3.small
• Storage: 20 GB SSD (gp3)
• Multi-AZ: Enabled
• Backups: 7 jours
• Region: af-south-1
• Encryption: AES-256
```

**Redis ElastiCache** :
```
Redis Cache (AWS ElastiCache)

• Instance: cache.t3.micro
• Engine: Redis 7.0
• Use Case: Session Store, Cache
• TTL: 15 minutes
• Eviction: allkeys-lru
```

**Azure Monitor** :
```
Azure Monitor

• Log Analytics Workspace
• Application Insights
• Alertes: Email, SMS, Webhook
• Retention: 90 jours
• Region: South Africa North
```

### Zones

**Zone AWS** :
```
AWS Region: af-south-1 (Cape Town)
Latence depuis Douala: 80-100ms
Zones de Disponibilité: 3 AZ
```

**Zone Azure** :
```
Azure Region: South Africa North
Johannesburg, Afrique du Sud
Services: Azure AD, Azure Monitor
```

### Légende
```
LÉGENDE

🔵 AWS Services
🔷 Azure Services
👥 Utilisateurs
─→ Flux de données
🔒 Chiffrement TLS 1.3
```

### Métriques
```
MÉTRIQUES CLÉS

Latence: < 100ms
Utilisateurs: 50 simultanés
Disponibilité: 99.5%
Coût mensuel: ~$90
Région: Afrique du Sud
```

---

## SCHÉMA 2 : Architecture Multi-AZ

### Titre
```
Architecture Multi-AZ pour Haute Disponibilité
AWS Region: af-south-1 (Cape Town)
```

### Availability Zone A
```
Availability Zone A

• RDS Primary (Read/Write)
• Lambda (Auto-distributed)
• ElastiCache Primary
```

### Availability Zone B
```
Availability Zone B

• RDS Standby (Failover)
• Lambda (Auto-distributed)
• ElastiCache Replica
```

### Réplication
```
Synchronous Replication
Latence: < 1ms
Failover: < 60s
```

### S3 Global
```
AWS S3 (Global)

• Réplication automatique 3+ AZ
• Disponibilité: 99.99%
• Durabilité: 99.999999999%
```

### Annotations
```
RÉSILIENCE

✅ Multi-AZ automatique
✅ Failover < 60s
✅ Backups automatiques (7j)
✅ SLA 99.95%
✅ Point-in-Time Recovery
```

---

## SCHÉMA 3 : Flux d'Authentification

### Titre
```
Flux d'Authentification Azure AD (OAuth 2.0)
Sécurité et Contrôle d'Accès
```

### Étapes

**Étape 1** :
```
1. Accès Application
Utilisateur → Frontend
URL: https://crm.agrocam.cm
```

**Étape 2** :
```
2. Redirection OAuth 2.0
Frontend → Azure AD
Redirect URI + Client ID
```

**Étape 3** :
```
3. Authentification
Utilisateur → Azure AD
Login + Password + MFA
```

**Étape 4** :
```
4. JWT Token
Azure AD → Frontend
Token Lifetime: 1 heure
Refresh Token: 90 jours
```

**Étape 5** :
```
5. Requête API
Frontend → Backend
GET /api/clients
Authorization: Bearer <token>
```

**Étape 6** :
```
6. Validation Token
Backend → Azure AD
Vérification signature JWT
Vérification expiration
```

**Étape 7** :
```
7. Vérification RBAC
Backend (Lambda)
Rôle: Admin / Manager / Agent
Permissions vérifiées
```

**Étape 8** :
```
8. Accès Base de Données
Backend → PostgreSQL
Requête SQL autorisée
Données retournées
```

### Encadré Sécurité
```
MESURES DE SÉCURITÉ

✅ OAuth 2.0 / OpenID Connect
✅ MFA obligatoire (SMS, App)
✅ Token expiration: 1h
✅ RBAC: 3 rôles
✅ HTTPS (TLS 1.3)
✅ Chiffrement AES-256
✅ Audit logs (CloudTrail)
✅ Rate limiting: 100 req/min
```

### Rôles RBAC
```
RÔLES ET PERMISSIONS

Admin:
• Gestion utilisateurs
• Configuration système
• Accès complet

Manager:
• Gestion clients
• Rapports avancés
• Gestion équipe

Agent:
• Consultation clients
• Création interactions
• Rapports basiques
```

---

## ANNOTATIONS COMMUNES

### Performance
```
PERFORMANCE

⚡ Latence API: < 500ms
⚡ Temps chargement: < 2s
⚡ Throughput: 100 req/s
⚡ Cache hit rate: 80%
```

### Coûts
```
COÛTS MENSUELS

AWS:
• RDS: $40
• S3: $3
• CloudFront: $10
• Lambda: $5
• ElastiCache: $15
• Autres: $7
Total AWS: $80

Azure:
• Azure AD: Gratuit
• Azure Monitor: $10
Total Azure: $10

TOTAL: ~$90/mois
```

### Conformité
```
CONFORMITÉ

✅ Loi camerounaise n°2010/012
✅ Hébergement Afrique du Sud
✅ RGPD (si applicable)
✅ Souveraineté des données
✅ Audit logs obligatoires
```

### Contact
```
PROJET DIGITRANS-CM

Client: AGROCAM S.A.
Prestataire: CAMTECH SOLUTIONS
Budget: 480M FCFA
Durée: 18 mois
Date: Janvier 2025
```

---

## 🎨 Codes Couleurs (Hexadécimal)

```
AWS Orange: #FF9900
AWS Bleu: #232F3E
Azure Bleu: #0078D4
Azure Bleu Clair: #50E6FF
Vert Succès: #28A745
Rouge Erreur: #DC3545
Jaune Warning: #FFC107
Gris Texte: #6C757D
Noir: #000000
Blanc: #FFFFFF
```

---

## 📐 Dimensions Recommandées

```
Taille Canvas: 1920 x 1080 px (16:9)
Marges: 50 px de chaque côté
Espacement éléments: 30 px
Taille icônes: 64 x 64 px
Taille texte titre: 24 pt
Taille texte normal: 12 pt
Taille texte annotations: 10 pt
```

---

## ✅ Checklist Qualité

### Avant Export
- [ ] Tous les textes sont lisibles
- [ ] Pas de fautes d'orthographe
- [ ] Alignement correct
- [ ] Couleurs cohérentes
- [ ] Flèches bien orientées
- [ ] Légende présente
- [ ] Titre clair
- [ ] Annotations pertinentes

### Export
- [ ] Format PNG, 300 DPI
- [ ] Taille > 1920x1080
- [ ] Fond blanc ou transparent
- [ ] Qualité maximale
- [ ] Nom de fichier descriptif

---

**Copiez ces textes dans EdrawMax pour gagner du temps !** ⏱️
