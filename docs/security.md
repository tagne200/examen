# Politique de Sécurité - DIGITRANS-CM CRM

## Vue d'Ensemble

Ce document décrit les mesures de sécurité implémentées dans le module CRM du projet DIGITRANS-CM pour protéger les données sensibles d'AGROCAM S.A.

---

## 1. Authentification et Autorisation

### Azure Active Directory (Azure AD)
- **Protocole** : OAuth 2.0 / OpenID Connect
- **Type de tokens** : JWT (JSON Web Tokens)
- **Durée de validité** : 1 heure
- **Refresh tokens** : Activés
- **MFA** : Recommandé pour tous les utilisateurs

### Rôles et Permissions (RBAC)
| Rôle | Permissions |
|------|-------------|
| **Admin** | Accès complet (CRUD sur toutes les ressources) |
| **Manager** | Lecture/Écriture clients, contacts, interactions |
| **Agent** | Lecture clients, Écriture interactions uniquement |

### Validation des Tokens
```python
# Vérification systématique des tokens JWT
# Validation de la signature avec clés publiques Azure AD
# Vérification de l'expiration
# Vérification de l'audience (client_id)
# Vérification de l'émetteur (tenant_id)
```

---

## 2. Chiffrement

### En Transit (TLS/SSL)
- ✅ **HTTPS obligatoire** en production
- ✅ TLS 1.3 minimum
- ✅ Certificats SSL/TLS valides
- ✅ HSTS (HTTP Strict Transport Security) activé

### Au Repos
- ✅ **Base de données RDS** : Chiffrement AES-256
- ✅ **S3 Buckets** : Chiffrement côté serveur (SSE-S3)
- ✅ **Secrets** : AWS Secrets Manager / Azure Key Vault
- ✅ **Backups** : Chiffrés automatiquement

### Données Sensibles
- ❌ **Jamais** stocker de mots de passe en clair
- ❌ **Jamais** logger de tokens ou credentials
- ✅ Utiliser des variables d'environnement pour les secrets
- ✅ Rotation régulière des clés (tous les 90 jours)

---

## 3. Protection des Données

### Données Personnelles (RGPD/Loi Camerounaise)
- ✅ Consentement explicite pour la collecte
- ✅ Droit d'accès, de rectification, de suppression
- ✅ Minimisation des données collectées
- ✅ Durée de conservation limitée (5 ans max)
- ✅ Traçabilité des accès

### Souveraineté des Données
- ✅ Données clients/RH : **Hébergement Cameroun ou Afrique uniquement**
- ✅ Conformité avec la loi n°2010/012
- ✅ Pas de transfert hors Afrique sans autorisation

### Sauvegarde et Récupération
- ✅ Backups automatiques quotidiens (RDS)
- ✅ Rétention : 7 jours (dev), 30 jours (prod)
- ✅ Tests de restauration mensuels
- ✅ Backups chiffrés et géo-répliqués

---

## 4. Sécurité Applicative

### Protection OWASP Top 10

#### 1. Injection SQL
```python
# ✅ Utilisation de SQLAlchemy ORM
# ✅ Requêtes paramétrées uniquement
# ❌ Pas de concaténation de strings SQL
```

#### 2. Broken Authentication
```python
# ✅ Azure AD pour l'authentification
# ✅ Tokens JWT avec expiration
# ✅ Pas de sessions côté serveur
```

#### 3. Sensitive Data Exposure
```python
# ✅ HTTPS obligatoire
# ✅ Pas de données sensibles dans les logs
# ✅ Chiffrement au repos
```

#### 4. XML External Entities (XXE)
```python
# ✅ Pas d'utilisation de XML
# ✅ JSON uniquement
```

#### 5. Broken Access Control
```python
# ✅ Vérification des permissions sur chaque endpoint
# ✅ RBAC avec Azure AD
# ✅ Validation de l'ownership des ressources
```

#### 6. Security Misconfiguration
```python
# ✅ Pas de credentials en dur dans le code
# ✅ Variables d'environnement pour la config
# ✅ Désactivation des endpoints de debug en prod
```

#### 7. Cross-Site Scripting (XSS)
```javascript
// ✅ Sanitization des inputs côté client
// ✅ Content-Security-Policy headers
// ✅ Pas d'innerHTML avec données utilisateur
```

#### 8. Insecure Deserialization
```python
# ✅ Validation stricte des données JSON
# ✅ Pydantic pour la validation des schémas
```

#### 9. Using Components with Known Vulnerabilities
```bash
# ✅ Mise à jour régulière des dépendances
# ✅ Scan de vulnérabilités avec pip-audit
pip-audit
```

#### 10. Insufficient Logging & Monitoring
```python
# ✅ Logs centralisés (Azure Monitor)
# ✅ Alertes automatiques
# ✅ Audit trail complet
```

### Validation des Entrées
```python
# ✅ Validation avec Pydantic
# ✅ Sanitization des strings
# ✅ Limitation de la taille des requêtes
# ✅ Rate limiting (100 req/min/user)
```

### Protection CSRF
```python
# ✅ Tokens CSRF pour les formulaires
# ✅ SameSite cookies
# ✅ Vérification de l'origine des requêtes
```

### CORS (Cross-Origin Resource Sharing)
```python
# ✅ Liste blanche des origines autorisées
# ✅ Pas de wildcard (*) en production
# ✅ Credentials autorisés uniquement pour origines de confiance
```

---

## 5. Infrastructure Cloud

### AWS Security Best Practices
- ✅ **IAM** : Principe du moindre privilège
- ✅ **Security Groups** : Règles restrictives
- ✅ **VPC** : Isolation réseau
- ✅ **CloudTrail** : Audit des actions AWS
- ✅ **GuardDuty** : Détection de menaces
- ✅ **AWS WAF** : Protection contre attaques web

### Azure Security Best Practices
- ✅ **Azure AD** : Authentification centralisée
- ✅ **RBAC** : Contrôle d'accès granulaire
- ✅ **Security Center** : Recommandations de sécurité
- ✅ **Key Vault** : Gestion des secrets
- ✅ **Monitor** : Logs et alertes

### Network Security
```
Internet
    ↓
CloudFront (CDN) → WAF
    ↓
API Gateway → Rate Limiting
    ↓
Lambda/EC2 (Private Subnet)
    ↓
RDS (Private Subnet, Security Group)
```

---

## 6. Monitoring et Détection

### Logs Collectés
- ✅ Authentifications (succès/échecs)
- ✅ Accès aux ressources
- ✅ Modifications de données
- ✅ Erreurs applicatives
- ✅ Tentatives d'accès non autorisées

### Alertes Configurées
| Événement | Seuil | Action |
|-----------|-------|--------|
| Échecs d'authentification | 5 en 5 min | Email + SMS |
| Erreurs 500 | > 10/min | Email équipe tech |
| Temps de réponse | > 5s | Email DevOps |
| Utilisation CPU | > 80% | Auto-scaling |
| Tentatives SQL injection | 1 | Blocage IP + alerte |

### Audit Trail
```sql
-- Toutes les actions sont tracées
SELECT 
    user_id,
    action,
    resource,
    timestamp
FROM audit_log
WHERE timestamp > NOW() - INTERVAL '24 hours';
```

---

## 7. Gestion des Incidents

### Procédure en Cas de Faille
1. **Détection** : Alertes automatiques
2. **Isolation** : Blocage de l'accès compromis
3. **Investigation** : Analyse des logs
4. **Correction** : Patch de sécurité
5. **Communication** : Notification client (AGROCAM)
6. **Post-mortem** : Rapport d'incident

### Contacts d'Urgence
- **Responsable Sécurité** : security@camtech.cm
- **Équipe DevOps** : devops@camtech.cm
- **Hotline 24/7** : +237 XXX XXX XXX

---

## 8. Conformité Réglementaire

### Loi Camerounaise n°2010/012
- ✅ Protection des données personnelles
- ✅ Traçabilité des accès
- ✅ Hébergement local des données sensibles
- ✅ Déclaration ANTIC (si requis)

### Standards Internationaux
- ✅ ISO 27001 (en cours de certification)
- ✅ OWASP Top 10
- ✅ CIS Benchmarks (AWS/Azure)

---

## 9. Formation et Sensibilisation

### Équipe Technique
- ✅ Formation sécurité annuelle obligatoire
- ✅ Code reviews systématiques
- ✅ Tests de pénétration semestriels

### Utilisateurs Finaux
- ✅ Guide de bonnes pratiques
- ✅ Sensibilisation au phishing
- ✅ Politique de mots de passe forts

---

## 10. Checklist de Sécurité

### Avant Déploiement
- [ ] Tous les secrets dans des variables d'environnement
- [ ] HTTPS activé et certificat valide
- [ ] Azure AD configuré correctement
- [ ] Rate limiting activé
- [ ] Logs et monitoring configurés
- [ ] Backups automatiques activés
- [ ] Security Groups restrictifs
- [ ] Tests de sécurité passés
- [ ] Documentation à jour

### Maintenance Régulière
- [ ] Mise à jour des dépendances (mensuel)
- [ ] Rotation des secrets (trimestriel)
- [ ] Revue des logs (hebdomadaire)
- [ ] Tests de restauration (mensuel)
- [ ] Audit de sécurité (semestriel)

---

## Contact

Pour toute question de sécurité :
- **Email** : security@camtech.cm
- **Responsable** : [Nom du RSSI]
- **Téléphone** : +237 XXX XXX XXX

---

**Dernière mise à jour** : Janvier 2025  
**Version** : 1.0  
**Statut** : Approuvé
