/**
 * Gestionnaire d'appels API
 */

class ApiClient {
    constructor() {
        this.baseUrl = CONFIG.API_URL;
    }

    /**
     * Effectuer une requête HTTP
     */
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        
        const headers = {
            'Content-Type': 'application/json',
            ...options.headers
        };

        // Ajouter le token d'authentification
        const token = authManager.getToken();
        if (token) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        try {
            const response = await fetch(url, {
                ...options,
                headers
            });

            // Gérer les erreurs HTTP
            if (!response.ok) {
                const error = await response.json().catch(() => ({}));
                throw new Error(error.detail || `Erreur HTTP ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            console.error('Erreur API:', error);
            throw error;
        }
    }

    /**
     * GET request
     */
    async get(endpoint, params = {}) {
        const queryString = new URLSearchParams(params).toString();
        const url = queryString ? `${endpoint}?${queryString}` : endpoint;
        return this.request(url, { method: 'GET' });
    }

    /**
     * POST request
     */
    async post(endpoint, data) {
        return this.request(endpoint, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    /**
     * PUT request
     */
    async put(endpoint, data) {
        return this.request(endpoint, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    /**
     * DELETE request
     */
    async delete(endpoint) {
        return this.request(endpoint, { method: 'DELETE' });
    }

    // ============= CLIENTS =============

    async getClients(params = {}) {
        return this.get('/clients', params);
    }

    async getClient(id) {
        return this.get(`/clients/${id}`);
    }

    async createClient(data) {
        return this.post('/clients', data);
    }

    async updateClient(id, data) {
        return this.put(`/clients/${id}`, data);
    }

    async deleteClient(id) {
        return this.delete(`/clients/${id}`);
    }

    // ============= CONTACTS =============

    async getClientContacts(clientId) {
        return this.get(`/clients/${clientId}/contacts`);
    }

    async createContact(data) {
        return this.post('/contacts', data);
    }

    async deleteContact(id) {
        return this.delete(`/contacts/${id}`);
    }

    // ============= INTERACTIONS =============

    async getInteractions(params = {}) {
        return this.get('/interactions', params);
    }

    async createInteraction(data) {
        return this.post('/interactions', data);
    }

    // ============= STATISTIQUES =============

    async getDashboardStats() {
        return this.get('/stats/dashboard');
    }
}

// Instance globale
const api = new ApiClient();

/**
 * Afficher un message de succès
 */
function showSuccess(message) {
    const toast = `
        <div class="toast align-items-center text-white bg-success border-0 position-fixed top-0 end-0 m-3" role="alert" style="z-index: 9999;">
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-check-circle me-2"></i> ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    `;
    document.body.insertAdjacentHTML('beforeend', toast);
    const toastEl = document.body.lastElementChild;
    const bsToast = new bootstrap.Toast(toastEl, { delay: 3000 });
    bsToast.show();
    toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
}

/**
 * Afficher un message d'erreur
 */
function showError(message) {
    const toast = `
        <div class="toast align-items-center text-white bg-danger border-0 position-fixed top-0 end-0 m-3" role="alert" style="z-index: 9999;">
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-exclamation-circle me-2"></i> ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    `;
    document.body.insertAdjacentHTML('beforeend', toast);
    const toastEl = document.body.lastElementChild;
    const bsToast = new bootstrap.Toast(toastEl, { delay: 5000 });
    bsToast.show();
    toastEl.addEventListener('hidden.bs.toast', () => toastEl.remove());
}

/**
 * Afficher un loader
 */
function showLoader() {
    const loader = `
        <div id="global-loader" class="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center" style="background: rgba(0,0,0,0.5); z-index: 9998;">
            <div class="spinner-border text-light" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Chargement...</span>
            </div>
        </div>
    `;
    if (!document.getElementById('global-loader')) {
        document.body.insertAdjacentHTML('beforeend', loader);
    }
}

/**
 * Masquer le loader
 */
function hideLoader() {
    const loader = document.getElementById('global-loader');
    if (loader) {
        loader.remove();
    }
}
