/**
 * Gestion de la navigation et de l'application
 */

// Router simple
const router = {
    currentPage: 'dashboard',
    
    navigate(page) {
        this.currentPage = page;
        
        // Mettre à jour le menu actif
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
            if (link.dataset.page === page) {
                link.classList.add('active');
            }
        });
        
        // Mettre à jour le titre et breadcrumb
        const titles = {
            dashboard: 'Tableau de bord',
            clients: 'Gestion des Clients',
            contacts: 'Gestion des Contacts',
            interactions: 'Historique des Interactions',
            settings: 'Paramètres'
        };
        
        document.getElementById('page-title').textContent = titles[page] || page;
        document.getElementById('breadcrumb-current').textContent = titles[page] || page;
        
        // Charger le contenu de la page
        this.loadPage(page);
    },
    
    loadPage(page) {
        const content = document.getElementById('main-content');
        
        switch(page) {
            case 'dashboard':
                loadDashboard();
                break;
            case 'clients':
                loadClients();
                break;
            case 'interactions':
                loadInteractions();
                break;
            case 'contacts':
                content.innerHTML = '<div class="alert alert-info">Page Contacts en cours de développement</div>';
                break;
            case 'settings':
                content.innerHTML = '<div class="alert alert-info">Page Paramètres en cours de développement</div>';
                break;
            default:
                content.innerHTML = '<div class="alert alert-warning">Page non trouvée</div>';
        }
    }
};

// Initialisation au chargement
document.addEventListener('DOMContentLoaded', () => {
    // Gérer les clics sur le menu
    document.querySelectorAll('[data-page]').forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            const page = e.currentTarget.dataset.page;
            router.navigate(page);
        });
    });
    
    // Charger la page initiale
    router.navigate('dashboard');
});

/**
 * Formater une date
 */
function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

/**
 * Formater une date courte
 */
function formatDateShort(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR');
}
