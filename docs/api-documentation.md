# Documentation API - Module CRM DIGITRANS-CM

## Base URL
```
Production: https://votre-api-gateway.amazonaws.com/prod/api
Développement: http://localhost:8000/api
```

## Authentification

Toutes les requêtes API nécessitent un token JWT Azure AD dans le header Authorization :

```http
Authorization: Bearer <votre-token-jwt>
```

---

## Endpoints

### Health Check

#### GET /health
Vérifier l'état de l'API

**Réponse**
```json
{
  "status": "healthy",
  "service": "DIGITRANS-CM CRM API",
  "version": "1.0.0"
}
```

---

## Clients

### GET /api/clients
Récupérer la liste des clients

**Paramètres de requête**
- `skip` (int, optionnel) : Nombre d'éléments à sauter (pagination)
- `limit` (int, optionnel) : Nombre maximum d'éléments à retourner (max 1000)
- `search` (string, optionnel) : Recherche par nom ou email
- `ville` (string, optionnel) : Filtrer par ville
- `statut` (string, optionnel) : Filtrer par statut (actif, inactif, prospect)

**Exemple de requête**
```bash
curl -X GET "http://localhost:8000/api/clients?limit=10&ville=Douala" \
  -H "Authorization: Bearer <token>"
```

**Réponse**
```json
{
  "total": 45,
  "skip": 0,
  "limit": 10,
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "nom": "Restaurant Le Palmier",
      "email": "contact@lepalmier.cm",
      "telephone": "+237 699 123 456",
      "adresse": "Rue de la Liberté, Akwa",
      "ville": "Douala",
      "statut": "actif",
      "created_at": "2025-01-15T10:30:00Z",
      "updated_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

### POST /api/clients
Créer un nouveau client

**Corps de la requête**
```json
{
  "nom": "Restaurant Le Palmier",
  "email": "contact@lepalmier.cm",
  "telephone": "+237 699 123 456",
  "adresse": "Rue de la Liberté, Akwa",
  "ville": "Douala",
  "statut": "actif"
}
```

**Réponse (201 Created)**
```json
{
  "message": "Client créé avec succès",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "nom": "Restaurant Le Palmier",
    ...
  }
}
```

---

### GET /api/clients/{client_id}
Récupérer les détails d'un client

**Paramètres**
- `client_id` (UUID) : Identifiant du client

**Réponse**
```json
{
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "nom": "Restaurant Le Palmier",
    "email": "contact@lepalmier.cm",
    "contacts": [
      {
        "id": "...",
        "nom": "Dupont",
        "prenom": "Jean",
        "fonction": "Gérant"
      }
    ],
    "interactions": [
      {
        "id": "...",
        "type": "appel",
        "sujet": "Commande spéciale",
        "date_interaction": "2025-01-20T14:30:00Z"
      }
    ]
  }
}
```

---

### PUT /api/clients/{client_id}
Mettre à jour un client

**Corps de la requête** (tous les champs sont optionnels)
```json
{
  "nom": "Restaurant Le Palmier Doré",
  "statut": "inactif"
}
```

**Réponse**
```json
{
  "message": "Client mis à jour avec succès",
  "data": { ... }
}
```

---

### DELETE /api/clients/{client_id}
Supprimer un client (et ses contacts/interactions en cascade)

**Réponse**
```json
{
  "message": "Client supprimé avec succès"
}
```

---

## Contacts

### GET /api/clients/{client_id}/contacts
Récupérer tous les contacts d'un client

**Réponse**
```json
{
  "total": 3,
  "data": [
    {
      "id": "...",
      "client_id": "...",
      "nom": "Dupont",
      "prenom": "Jean",
      "fonction": "Gérant",
      "email": "jean.dupont@lepalmier.cm",
      "telephone": "+237 699 111 222",
      "created_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

### POST /api/contacts
Créer un nouveau contact

**Corps de la requête**
```json
{
  "client_id": "123e4567-e89b-12d3-a456-426614174000",
  "nom": "Dupont",
  "prenom": "Jean",
  "fonction": "Gérant",
  "email": "jean.dupont@lepalmier.cm",
  "telephone": "+237 699 111 222"
}
```

**Réponse (201 Created)**
```json
{
  "message": "Contact créé avec succès",
  "data": { ... }
}
```

---

### DELETE /api/contacts/{contact_id}
Supprimer un contact

**Réponse**
```json
{
  "message": "Contact supprimé avec succès"
}
```

---

## Interactions

### GET /api/interactions
Récupérer la liste des interactions

**Paramètres de requête**
- `skip` (int, optionnel) : Pagination
- `limit` (int, optionnel) : Limite (max 1000)
- `client_id` (UUID, optionnel) : Filtrer par client
- `type` (string, optionnel) : Filtrer par type (appel, email, visite, reunion)

**Réponse**
```json
{
  "total": 120,
  "skip": 0,
  "limit": 100,
  "data": [
    {
      "id": "...",
      "client_id": "...",
      "type": "appel",
      "sujet": "Commande spéciale",
      "description": "Discussion sur une commande de 500 kg de cacao",
      "date_interaction": "2025-01-20T14:30:00Z",
      "user_id": "azure-ad-user-id",
      "created_at": "2025-01-20T14:35:00Z"
    }
  ]
}
```

---

### POST /api/interactions
Créer une nouvelle interaction

**Corps de la requête**
```json
{
  "client_id": "123e4567-e89b-12d3-a456-426614174000",
  "type": "appel",
  "sujet": "Commande spéciale",
  "description": "Discussion sur une commande de 500 kg de cacao",
  "date_interaction": "2025-01-20T14:30:00Z"
}
```

**Réponse (201 Created)**
```json
{
  "message": "Interaction créée avec succès",
  "data": { ... }
}
```

---

## Statistiques

### GET /api/stats/dashboard
Récupérer les statistiques du tableau de bord

**Réponse**
```json
{
  "total_clients": 45,
  "clients_actifs": 38,
  "total_interactions": 320,
  "interactions_by_type": {
    "appel": 150,
    "email": 80,
    "visite": 60,
    "reunion": 30
  }
}
```

---

## Codes d'Erreur

| Code | Description |
|------|-------------|
| 200 | Succès |
| 201 | Créé avec succès |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Accès refusé |
| 404 | Ressource non trouvée |
| 500 | Erreur serveur |

**Format d'erreur**
```json
{
  "detail": "Message d'erreur détaillé"
}
```

---

## Exemples avec cURL

### Créer un client
```bash
curl -X POST "http://localhost:8000/api/clients" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Restaurant Test",
    "email": "test@example.cm",
    "ville": "Douala",
    "statut": "actif"
  }'
```

### Récupérer les clients de Douala
```bash
curl -X GET "http://localhost:8000/api/clients?ville=Douala&limit=20" \
  -H "Authorization: Bearer <token>"
```

### Créer une interaction
```bash
curl -X POST "http://localhost:8000/api/interactions" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "123e4567-e89b-12d3-a456-426614174000",
    "type": "appel",
    "sujet": "Suivi commande",
    "date_interaction": "2025-01-20T10:00:00Z"
  }'
```

---

## Rate Limiting

- **Limite** : 100 requêtes par minute par utilisateur
- **Header de réponse** : `X-RateLimit-Remaining`

---

## Documentation Interactive

Accéder à la documentation Swagger interactive :
- **Swagger UI** : http://localhost:8000/docs
- **ReDoc** : http://localhost:8000/redoc
