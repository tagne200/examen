/**
 * Gestion de l'authentification Azure AD
 */

class AuthManager {
    constructor() {
        this.token = localStorage.getItem('access_token');
        this.user = JSON.parse(localStorage.getItem('user') || 'null');
    }

    /**
     * Vérifier si l'utilisateur est authentifié
     */
    isAuthenticated() {
        return !!this.token;
    }

    /**
     * Obtenir le token d'accès
     */
    getToken() {
        return this.token;
    }

    /**
     * Obtenir les informations de l'utilisateur
     */
    getUser() {
        return this.user;
    }

    /**
     * Connexion (redirection vers Azure AD)
     */
    login() {
        // En mode développement, utiliser un token factice
        if (CONFIG.API_URL.includes('localhost')) {
            this.loginDev();
            return;
        }

        // En production, rediriger vers Azure AD
        const authUrl = `https://login.microsoftonline.com/${CONFIG.AZURE_TENANT_ID}/oauth2/v2.0/authorize?` +
            `client_id=${CONFIG.AZURE_CLIENT_ID}` +
            `&response_type=token` +
            `&redirect_uri=${encodeURIComponent(CONFIG.AZURE_REDIRECT_URI)}` +
            `&scope=openid%20profile%20email` +
            `&response_mode=fragment`;
        
        window.location.href = authUrl;
    }

    /**
     * Connexion en mode développement (sans Azure AD)
     */
    loginDev() {
        const devToken = 'dev-token-' + Date.now();
        const devUser = {
            sub: 'dev-user-id',
            name: 'Utilisateur Test',
            email: 'test@camtech.cm',
            roles: ['admin']
        };

        this.token = devToken;
        this.user = devUser;

        localStorage.setItem('access_token', devToken);
        localStorage.setItem('user', JSON.stringify(devUser));

        console.log('✅ Connexion en mode développement');
        window.location.reload();
    }

    /**
     * Traiter le callback Azure AD
     */
    handleCallback() {
        const hash = window.location.hash.substring(1);
        const params = new URLSearchParams(hash);
        
        const accessToken = params.get('access_token');
        
        if (accessToken) {
            this.token = accessToken;
            localStorage.setItem('access_token', accessToken);
            
            // Décoder le token pour obtenir les infos utilisateur
            try {
                const payload = this.parseJwt(accessToken);
                this.user = {
                    sub: payload.sub,
                    name: payload.name || payload.preferred_username,
                    email: payload.email || payload.preferred_username,
                    roles: payload.roles || []
                };
                localStorage.setItem('user', JSON.stringify(this.user));
            } catch (e) {
                console.error('Erreur lors du décodage du token:', e);
            }
            
            // Rediriger vers la page principale
            window.location.href = '/';
        }
    }

    /**
     * Déconnexion
     */
    logout() {
        this.token = null;
        this.user = null;
        localStorage.removeItem('access_token');
        localStorage.removeItem('user');
        
        // En production, rediriger vers la déconnexion Azure AD
        if (!CONFIG.API_URL.includes('localhost')) {
            const logoutUrl = `https://login.microsoftonline.com/${CONFIG.AZURE_TENANT_ID}/oauth2/v2.0/logout?` +
                `post_logout_redirect_uri=${encodeURIComponent(window.location.origin)}`;
            window.location.href = logoutUrl;
        } else {
            window.location.reload();
        }
    }

    /**
     * Décoder un JWT (sans vérification de signature)
     */
    parseJwt(token) {
        const base64Url = token.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(atob(base64).split('').map(c => {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));
        return JSON.parse(jsonPayload);
    }
}

// Instance globale
const authManager = new AuthManager();

// Vérifier l'authentification au chargement
document.addEventListener('DOMContentLoaded', () => {
    // Si on est sur la page de callback
    if (window.location.pathname.includes('callback')) {
        authManager.handleCallback();
        return;
    }

    // Si non authentifié, rediriger vers la connexion
    if (!authManager.isAuthenticated()) {
        authManager.login();
        return;
    }

    // Afficher le nom de l'utilisateur
    const user = authManager.getUser();
    if (user && user.name) {
        document.getElementById('user-name').textContent = user.name;
    }

    // Gérer la déconnexion
    document.getElementById('logout-btn')?.addEventListener('click', (e) => {
        e.preventDefault();
        authManager.logout();
    });
});
