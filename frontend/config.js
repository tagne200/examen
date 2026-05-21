/**
 * Configuration de l'application CRM DIGITRANS-CM
 */
const CONFIG = {
    // URL de l'API Backend
    API_URL: 'http://localhost:8000/api',
    
    // Configuration Azure AD
    AZURE_CLIENT_ID: 'votre-client-id-azure',
    AZURE_TENANT_ID: 'votre-tenant-id-azure',
    AZURE_REDIRECT_URI: window.location.origin + '/callback.html',
    
    // Configuration de l'application
    APP_NAME: 'DIGITRANS-CM CRM',
    APP_VERSION: '1.0.0',
    COMPANY_NAME: 'AGROCAM S.A.',
    
    // Pagination
    DEFAULT_PAGE_SIZE: 20,
    
    // Types d'interactions
    INTERACTION_TYPES: [
        { value: 'appel', label: 'Appel téléphonique', icon: 'phone' },
        { value: 'email', label: 'Email', icon: 'envelope' },
        { value: 'visite', label: 'Visite', icon: 'map-marker' },
        { value: 'reunion', label: 'Réunion', icon: 'users' }
    ],
    
    // Statuts clients
    CLIENT_STATUS: [
        { value: 'actif', label: 'Actif', class: 'success' },
        { value: 'inactif', label: 'Inactif', class: 'secondary' },
        { value: 'prospect', label: 'Prospect', class: 'info' }
    ],
    
    // Villes principales
    CITIES: [
        'Douala',
        'Yaoundé',
        'Bafoussam',
        'Garoua',
        'Ngaoundéré',
        'Bamenda',
        'Maroua',
        'Kribi'
    ]
};

// Export pour utilisation dans d'autres fichiers
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
