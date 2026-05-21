/**
 * Page Tableau de bord
 */

async function loadDashboard() {
    const content = document.getElementById('main-content');
    
    content.innerHTML = `
        <div class="row">
            <div class="col-lg-3 col-6">
                <div class="small-box bg-info">
                    <div class="inner">
                        <h3 id="stat-total-clients">-</h3>
                        <p>Total Clients</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-users"></i>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-3 col-6">
                <div class="small-box bg-success">
                    <div class="inner">
                        <h3 id="stat-clients-actifs">-</h3>
                        <p>Clients Actifs</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-user-check"></i>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-3 col-6">
                <div class="small-box bg-warning">
                    <div class="inner">
                        <h3 id="stat-interactions">-</h3>
                        <p>Interactions</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-comments"></i>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-3 col-6">
                <div class="small-box bg-danger">
                    <div class="inner">
                        <h3 id="stat-appels">-</h3>
                        <p>Appels ce mois</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-phone"></i>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="fas fa-chart-pie mr-1"></i>
                            Interactions par Type
                        </h3>
                    </div>
                    <div class="card-body">
                        <canvas id="interactions-chart" height="200"></canvas>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">
                            <i class="fas fa-clock mr-1"></i>
                            Dernières Interactions
                        </h3>
                    </div>
                    <div class="card-body p-0">
                        <ul class="products-list product-list-in-card pl-2 pr-2" id="recent-interactions">
                            <li class="item">
                                <div class="product-info">
                                    <span class="text-muted">Chargement...</span>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Charger les statistiques
    try {
        showLoader();
        const stats = await api.getDashboardStats();
        
        document.getElementById('stat-total-clients').textContent = stats.total_clients || 0;
        document.getElementById('stat-clients-actifs').textContent = stats.clients_actifs || 0;
        document.getElementById('stat-interactions').textContent = stats.total_interactions || 0;
        document.getElementById('stat-appels').textContent = stats.interactions_by_type?.appel || 0;
        
        // Charger les dernières interactions
        const interactions = await api.getInteractions({ limit: 5 });
        displayRecentInteractions(interactions.data || []);
        
        hideLoader();
    } catch (error) {
        hideLoader();
        showError('Erreur lors du chargement des statistiques');
        console.error(error);
    }
}

function displayRecentInteractions(interactions) {
    const container = document.getElementById('recent-interactions');
    
    if (interactions.length === 0) {
        container.innerHTML = '<li class="item"><div class="product-info"><span class="text-muted">Aucune interaction récente</span></div></li>';
        return;
    }
    
    container.innerHTML = interactions.map(interaction => {
        const typeIcons = {
            appel: 'phone',
            email: 'envelope',
            visite: 'map-marker-alt',
            reunion: 'users'
        };
        const icon = typeIcons[interaction.type] || 'comment';
        
        return `
            <li class="item">
                <div class="product-img">
                    <i class="fas fa-${icon} fa-2x text-primary"></i>
                </div>
                <div class="product-info">
                    <a href="#" class="product-title">
                        ${interaction.sujet || 'Sans sujet'}
                        <span class="badge badge-info float-right">${interaction.type}</span>
                    </a>
                    <span class="product-description">
                        ${formatDateShort(interaction.date_interaction)}
                    </span>
                </div>
            </li>
        `;
    }).join('');
}
