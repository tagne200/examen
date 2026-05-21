# DIGITRANS-CM - Module CRM

## Projet de Transformation Numérique pour AGROCAM S.A.

### Contexte
Projet de modernisation du système d'information d'AGROCAM S.A. dans le cadre du programme DIGITRANS-CM.
Ce repository contient l'implémentation du module CRM (Customer Relationship Management) pour la gestion de la relation client des restaurants SavoirManger.

### Architecture
- **Backend** : API REST Python (Flask/FastAPI)
- **Frontend** : Application Web HTML/JS
- **Cloud** : Architecture hybride AWS + Azure
- **Base de données** : PostgreSQL (AWS RDS - Région Afrique du Sud)
- **Authentification** : Azure AD (Entra ID)
- **Monitoring** : Azure Monitor

### Contraintes Techniques
- Hébergement données sensibles : Cameroun/Afrique
- Résilience : Mode dégradé en cas de coupure
- Latence optimisée : Régions cloud africaines
- Sécurité : Chiffrement bout en bout, RBAC

### Structure du Projet
```
examen/
├── backend/           # API REST Python
├── frontend/          # Application Web
├── infrastructure/    # Infrastructure as Code (Terraform)
├── docs/             # Documentation technique
└── scripts/          # Scripts de déploiement
```

### Démarrage Rapide
Voir [DEPLOYMENT.md](DEPLOYMENT.md) pour les instructions détaillées.

### Équipe
- **Entreprise** : CAMTECH SOLUTIONS S.A.
- **Client** : AGROCAM S.A.
- **Projet** : DIGITRANS-CM
- **Budget** : 480M FCFA
- **Durée** : 18 mois (Janvier 2026 - Juin 2027)

### Documentation
- [Architecture](ARCHITECTURE.md)
- [Guide de déploiement](DEPLOYMENT.md)
- [Rapport d'activité](RAPPORT_ACTIVITE.md)
- [Documentation API](docs/api-documentation.md)

### Licence
Propriété de CAMTECH SOLUTIONS S.A. - Tous droits réservés.
