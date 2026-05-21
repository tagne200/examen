# Frontend CRM DIGITRANS-CM

## Description
Interface web responsive pour le module CRM du projet DIGITRANS-CM.

## Technologies
- **HTML5 / CSS3 / JavaScript** (Vanilla JS)
- **Bootstrap 5** : Framework CSS
- **AdminLTE 3** : Template d'administration
- **Font Awesome 6** : Icônes

## Structure
```
frontend/
├── index.html              # Page principale
├── config.js               # Configuration
├── assets/
│   ├── css/
│   │   └── style.css      # Styles personnalisés
│   ├── js/
│   │   ├── auth.js        # Authentification Azure AD
│   │   ├── api.js         # Client API
│   │   ├── app.js         # Navigation et utilitaires
│   │   ├── dashboard.js   # Tableau de bord
│   │   ├── clients.js     # Gestion clients
│   │   └── interactions.js # Gestion interactions
│   └── img/               # Images et logos
```

## Configuration

### 1. Éditer config.js

```javascript
const CONFIG = {
    API_URL: 'http://localhost:8000/api',  // URL de votre API
    AZURE_CLIENT_ID: 'votre-client-id',
    AZURE_TENANT_ID: 'votre-tenant-id',
    // ...
};
```

### 2. Mode Développement (sans Azure AD)

L'application détecte automatiquement si l'API est en localhost et utilise un mode d'authentification simplifié pour le développement.

### 3. Mode Production

En production, l'authentification Azure AD est activée automatiquement.

## Déploiement Local

### Option 1 : Serveur HTTP Python
```bash
cd frontend
python -m http.server 3000
```
Accéder à : http://localhost:3000

### Option 2 : Live Server (VS Code)
1. Installer l'extension "Live Server"
2. Clic droit sur index.html → "Open with Live Server"

### Option 3 : Node.js http-server
```bash
npm install -g http-server
cd frontend
http-server -p 3000
```

## Déploiement AWS S3

```bash
# Uploader les fichiers
aws s3 sync . s3://digitrans-crm-frontend/ \
    --exclude "*.md" \
    --exclude ".git/*" \
    --region af-south-1

# Configurer le site web statique
aws s3 website s3://digitrans-crm-frontend \
    --index-document index.html \
    --error-document index.html
```

## Fonctionnalités

### ✅ Implémentées
- Authentification Azure AD (avec mode dev)
- Tableau de bord avec statistiques
- Gestion complète des clients (CRUD)
- Gestion des interactions
- Recherche et filtres
- Interface responsive
- Messages de succès/erreur (toasts)
- Loader global

### 🚧 À Développer
- Gestion détaillée des contacts
- Export Excel/PDF
- Graphiques avancés (Chart.js)
- Mode offline complet avec Service Worker
- Notifications push
- Paramètres utilisateur

## Mode Offline

Le mode offline basique est prévu mais non encore implémenté. Pour l'activer :

1. Créer un fichier `service-worker.js`
2. Enregistrer le Service Worker dans `index.html`
3. Implémenter le cache des ressources statiques
4. Ajouter IndexedDB pour les données

## Personnalisation

### Couleurs
Éditer les variables CSS dans `assets/css/style.css` :
```css
:root {
    --primary-color: #007bff;
    --success-color: #28a745;
    /* ... */
}
```

### Logo
Remplacer l'icône dans la sidebar :
```html
<i class="fas fa-building brand-image"></i>
```

## Compatibilité Navigateurs

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Edge 90+
- ✅ Safari 14+
- ⚠️ IE11 non supporté

## Performance

- Taille totale : ~50 KB (sans CDN)
- Temps de chargement : < 2s (avec CDN)
- Optimisations :
  - CDN pour Bootstrap, AdminLTE, Font Awesome
  - Lazy loading des pages
  - Minification CSS/JS recommandée en production

## Sécurité

- ✅ Tokens JWT stockés en localStorage
- ✅ HTTPS obligatoire en production
- ✅ Validation des inputs côté client
- ✅ Protection CSRF via tokens
- ⚠️ Pas de données sensibles en localStorage

## Support

Pour toute question ou problème :
- Email : support@camtech.cm
- Documentation API : `/docs/api-documentation.md`

---

**Développé par CAMTECH SOLUTIONS S.A. pour AGROCAM S.A.**
