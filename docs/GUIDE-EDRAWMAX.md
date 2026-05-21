# Guide EdrawMax - Création Architecture Cloud DIGITRANS-CM

## 🎯 Objectif
Créer 3 schémas professionnels pour documenter l'architecture cloud hybride AWS + Azure.

---

## 📋 Schémas à Créer

### 1. Architecture Globale (Vue d'ensemble)
### 2. Architecture Détaillée (Technique)
### 3. Flux d'Authentification (Azure AD)

---

## 🚀 Étape par Étape

### SCHÉMA 1 : Architecture Globale

#### A) Ouvrir EdrawMax

1. Lancer EdrawMax
2. Cliquer sur **"Nouveau"**
3. Chercher **"Cloud Architecture"** ou **"Network Diagram"**
4. Sélectionner un template vide

#### B) Ajouter les Bibliothèques AWS et Azure

1. Menu **"Bibliothèque"** (à gauche)
2. Cliquer sur **"+"** (Ajouter bibliothèque)
3. Chercher et ajouter :
   - ✅ **AWS Architecture Icons**
   - ✅ **Azure Architecture Icons**
   - ✅ **Network Symbols**

#### C) Créer le Schéma

**Structure** :
```
┌─────────────────────────────────────────────────────┐
│                  UTILISATEURS                        │
│         (50 agents commerciaux - Cameroun)          │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│              AZURE AD (Authentification)             │
│         Region: South Africa North                   │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│           AWS CloudFront (CDN Global)                │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌──────────────┐      ┌──────────────┐
│  Frontend    │      │   Backend    │
│  (S3)        │      │  (Lambda)    │
└──────────────┘      └──────┬───────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
            ┌──────────────┐  ┌──────────────┐
            │ PostgreSQL   │  │    Redis     │
            │   (RDS)      │  │ (ElastiCache)│
            └──────────────┘  └──────────────┘

┌─────────────────────────────────────────────────────┐
│         Azure Monitor (Supervision)                  │
│         Region: South Africa North                   │
└─────────────────────────────────────────────────────┘
```

**Éléments à ajouter** :

1. **Utilisateurs** (en haut)
   - Icône : "Users" ou "People"
   - Texte : "50 agents commerciaux - Douala, Yaoundé"

2. **Azure AD** (couche auth)
   - Icône : Azure "Active Directory"
   - Texte : "Azure AD (Entra ID)"
   - Sous-texte : "OAuth 2.0, MFA, RBAC"

3. **CloudFront** (CDN)
   - Icône : AWS "CloudFront"
   - Texte : "AWS CloudFront"
   - Sous-texte : "CDN Global, Edge Locations"

4. **Frontend** (S3)
   - Icône : AWS "S3"
   - Texte : "Frontend (S3)"
   - Sous-texte : "HTML/CSS/JS, Static Website"

5. **Backend** (Lambda)
   - Icône : AWS "Lambda"
   - Texte : "Backend API (Lambda)"
   - Sous-texte : "Python FastAPI, Serverless"

6. **PostgreSQL** (RDS)
   - Icône : AWS "RDS"
   - Texte : "PostgreSQL 15 (RDS)"
   - Sous-texte : "Multi-AZ, 20 GB, af-south-1"

7. **Redis** (ElastiCache)
   - Icône : AWS "ElastiCache"
   - Texte : "Redis Cache"
   - Sous-texte : "Session Store, TTL 15min"

8. **Azure Monitor** (en bas)
   - Icône : Azure "Monitor"
   - Texte : "Azure Monitor"
   - Sous-texte : "Logs, Alertes, Dashboards"

**Connexions** :
- Flèches avec labels : "HTTPS", "JWT Token", "SQL", "Cache"

#### D) Ajouter les Zones

**Zone AWS** (rectangle bleu clair) :
- Englober : CloudFront, S3, Lambda, RDS, ElastiCache
- Label : "AWS Region: af-south-1 (Cape Town)"

**Zone Azure** (rectangle bleu foncé) :
- Englober : Azure AD, Azure Monitor
- Label : "Azure Region: South Africa North"

#### E) Ajouter les Annotations

**Légende** (en bas à droite) :
```
┌─────────────────────────┐
│ LÉGENDE                 │
├─────────────────────────┤
│ 🔵 AWS Services         │
│ 🔷 Azure Services       │
│ 👥 Utilisateurs         │
│ ─→ Flux de données      │
└─────────────────────────┘
```

**Métriques clés** (en haut à droite) :
```
┌─────────────────────────┐
│ MÉTRIQUES               │
├─────────────────────────┤
│ Latence: < 100ms        │
│ Utilisateurs: 50        │
│ Disponibilité: 99.5%    │
│ Coût: ~$90/mois         │
└─────────────────────────┘
```

#### F) Sauvegarder

1. **Fichier** → **Enregistrer sous**
2. Nom : `architecture-globale-digitrans-cm.eddx`
3. Emplacement : `c:\Users\KENNETH\Desktop\Examen\docs\schemas\`

#### G) Exporter

1. **Fichier** → **Exporter**
2. Format : **PNG** (haute résolution, 300 DPI)
3. Nom : `architecture-globale.png`
4. Emplacement : `c:\Users\KENNETH\Desktop\Examen\docs\screenshots\`

---

### SCHÉMA 2 : Architecture Détaillée (Multi-AZ)

**Structure** :
```
┌─────────────────────────────────────────────────────┐
│         AWS Region: af-south-1 (Cape Town)          │
│                                                     │
│  ┌─────────────────────┐  ┌─────────────────────┐  │
│  │  Availability Zone A│  │  Availability Zone B│  │
│  │                     │  │                     │  │
│  │  ┌──────────────┐   │  │  ┌──────────────┐   │  │
│  │  │ RDS Primary  │◄──┼──┼─►│ RDS Standby  │   │  │
│  │  └──────────────┘   │  │  └──────────────┘   │  │
│  │                     │  │                     │  │
│  │  ┌──────────────┐   │  │  ┌──────────────┐   │  │
│  │  │Lambda (auto) │   │  │  │Lambda (auto) │   │  │
│  │  └──────────────┘   │  │  └──────────────┘   │  │
│  │                     │  │                     │  │
│  │  ┌──────────────┐   │  │  ┌──────────────┐   │  │
│  │  │Redis Primary │◄──┼──┼─►│Redis Replica │   │  │
│  │  └──────────────┘   │  │  └──────────────┘   │  │
│  └─────────────────────┘  └─────────────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         S3 (Réplication 3+ AZ)              │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**Éléments à ajouter** :

1. **Rectangle AWS Region** (englobant tout)
2. **2 rectangles AZ** (A et B)
3. **RDS Primary et Standby** avec flèche bidirectionnelle "Sync Replication"
4. **Lambda** dans chaque AZ (auto-distribué)
5. **Redis Primary et Replica** avec flèche "Async Replication"
6. **S3** en bas (global, pas d'AZ spécifique)

**Annotations** :
- "Failover automatique < 60s"
- "Multi-AZ pour haute disponibilité"
- "SLA 99.95%"

---

### SCHÉMA 3 : Flux d'Authentification (Azure AD)

**Structure** :
```
┌──────────┐
│Utilisateur│
└─────┬────┘
      │ 1. Accès application
      ▼
┌──────────────┐
│  Frontend    │
│   (S3)       │
└─────┬────────┘
      │ 2. Redirection vers Azure AD
      ▼
┌──────────────────┐
│   Azure AD       │
│  (Entra ID)      │
└─────┬────────────┘
      │ 3. Login + MFA
      │ 4. JWT Token (1h)
      ▼
┌──────────────┐
│  Frontend    │
└─────┬────────┘
      │ 5. Requête API + Token
      ▼
┌──────────────┐
│  Backend     │
│  (Lambda)    │
└─────┬────────┘
      │ 6. Validation Token
      │ 7. Vérification RBAC
      ▼
┌──────────────┐
│  PostgreSQL  │
│   (RDS)      │
└──────────────┘
```

**Éléments à ajouter** :

1. **Utilisateur** (icône personne)
2. **Frontend** (icône S3)
3. **Azure AD** (icône Azure AD)
4. **Backend** (icône Lambda)
5. **PostgreSQL** (icône RDS)

**Flèches numérotées** avec labels :
1. "Accès application"
2. "Redirection OAuth 2.0"
3. "Login + MFA"
4. "JWT Token (1h)"
5. "GET /api/clients + Bearer Token"
6. "Validation Token (Azure AD)"
7. "Vérification RBAC (Admin/Manager/Agent)"
8. "Requête SQL"

**Encadré sécurité** (à droite) :
```
┌─────────────────────────┐
│ SÉCURITÉ                │
├─────────────────────────┤
│ ✅ OAuth 2.0            │
│ ✅ MFA obligatoire      │
│ ✅ Token 1h expiration  │
│ ✅ RBAC (3 rôles)       │
│ ✅ HTTPS (TLS 1.3)      │
└─────────────────────────┘
```

---

## 🎨 Conseils de Design

### Couleurs
- **AWS** : Bleu clair (#FF9900 orange pour icônes)
- **Azure** : Bleu foncé (#0078D4)
- **Utilisateurs** : Vert (#28A745)
- **Flux de données** : Noir ou gris foncé

### Police
- **Titres** : Arial Bold, 14pt
- **Texte** : Arial Regular, 10pt
- **Annotations** : Arial Italic, 9pt

### Mise en Page
- **Marges** : 2cm de chaque côté
- **Espacement** : 1cm entre les éléments
- **Alignement** : Centré verticalement et horizontalement

---

## 📤 Export et Intégration

### Formats à Exporter

1. **PNG** (pour documentation)
   - Résolution : 300 DPI
   - Taille : 1920x1080 ou plus
   - Nom : `architecture-globale.png`

2. **SVG** (pour édition future)
   - Format vectoriel
   - Nom : `architecture-globale.svg`

3. **PDF** (si version payante)
   - Haute qualité
   - Nom : `architecture-globale.pdf`

### Emplacements

```
docs/
├── screenshots/
│   ├── architecture-globale.png
│   ├── architecture-multi-az.png
│   └── flux-authentification.png
└── schemas/
    ├── architecture-globale.eddx
    ├── architecture-multi-az.eddx
    └── flux-authentification.eddx
```

---

## 📝 Intégration dans la Documentation

### Dans C21-conception-architecture.md

Ajouter après la section 2.2 :

```markdown
### 2.2 Architecture Détaillée

![Architecture Globale](../screenshots/architecture-globale.png)
*Figure 1 : Architecture cloud hybride AWS + Azure*

![Architecture Multi-AZ](../screenshots/architecture-multi-az.png)
*Figure 2 : Résilience Multi-AZ*

![Flux d'Authentification](../screenshots/flux-authentification.png)
*Figure 3 : Flux d'authentification Azure AD*
```

---

## ⏱️ Temps Estimé

| Schéma | Temps | Difficulté |
|--------|-------|------------|
| Architecture Globale | 30 min | Facile |
| Architecture Multi-AZ | 20 min | Facile |
| Flux Authentification | 15 min | Facile |
| **TOTAL** | **1h** | **Facile** |

---

## 🎓 Tutoriels EdrawMax

### Vidéos YouTube
- **EdrawMax Basics** : https://www.youtube.com/watch?v=EdrawMax
- **AWS Architecture Diagrams** : https://www.youtube.com/results?search_query=edrawmax+aws
- **Azure Diagrams** : https://www.youtube.com/results?search_query=edrawmax+azure

### Documentation Officielle
- **Guide EdrawMax** : https://www.edrawmax.com/guide/
- **AWS Icons** : https://aws.amazon.com/architecture/icons/
- **Azure Icons** : https://docs.microsoft.com/azure/architecture/icons/

---

## ✅ Checklist

### Avant de Commencer
- [ ] EdrawMax installé ou accès en ligne
- [ ] Bibliothèques AWS et Azure ajoutées
- [ ] Dossiers créés (`docs/screenshots/`, `docs/schemas/`)

### Schéma 1 : Architecture Globale
- [ ] Utilisateurs ajoutés
- [ ] Azure AD ajouté
- [ ] Services AWS ajoutés (CloudFront, S3, Lambda, RDS, Redis)
- [ ] Azure Monitor ajouté
- [ ] Zones AWS et Azure délimitées
- [ ] Connexions et flèches ajoutées
- [ ] Légende et métriques ajoutées
- [ ] Exporté en PNG (300 DPI)

### Schéma 2 : Architecture Multi-AZ
- [ ] Région AWS délimitée
- [ ] 2 AZ créées (A et B)
- [ ] RDS Primary et Standby ajoutés
- [ ] Lambda distribué
- [ ] Redis Primary et Replica ajoutés
- [ ] S3 global ajouté
- [ ] Annotations failover ajoutées
- [ ] Exporté en PNG

### Schéma 3 : Flux Authentification
- [ ] Utilisateur ajouté
- [ ] Frontend ajouté
- [ ] Azure AD ajouté
- [ ] Backend ajouté
- [ ] PostgreSQL ajouté
- [ ] Flèches numérotées (1-8)
- [ ] Encadré sécurité ajouté
- [ ] Exporté en PNG

### Intégration
- [ ] Images copiées dans `docs/screenshots/`
- [ ] Fichiers sources dans `docs/schemas/`
- [ ] Références ajoutées dans `C21-conception-architecture.md`
- [ ] Commit et push sur GitHub

---

## 🎉 Résultat Final

**Vous aurez** :
- ✅ 3 schémas professionnels
- ✅ Architecture claire et compréhensible
- ✅ Documentation enrichie
- ✅ Preuves visuelles pour C21

**Temps total** : 1 heure

**Prêt à créer vos schémas ?** Lancez EdrawMax ! 🚀
