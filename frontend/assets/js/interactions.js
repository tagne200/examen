/**
 * Page Gestion des Interactions
 */

async function loadInteractions() {
    const content = document.getElementById('main-content');
    
    content.innerHTML = `
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Historique des Interactions</h3>
                <div class="card-tools">
                    <button type="button" class="btn btn-primary btn-sm" onclick="showInteractionModal()">
                        <i class="fas fa-plus"></i> Nouvelle Interaction
                    </button>
                </div>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-4">
                        <select class="form-control" id="filter-type">
                            <option value="">Tous les types</option>
                            ${CONFIG.INTERACTION_TYPES.map(t => `<option value="${t.value}">${t.label}</option>`).join('')}
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button class="btn btn-info btn-block" onclick="filterInteractions()">
                            <i class="fas fa-filter"></i> Filtrer
                        </button>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Sujet</th>
                                <th>Description</th>
                                <th>Client</th>
                            </tr>
                        </thead>
                        <tbody id="interactions-table-body">
                            <tr><td colspan="5" class="text-center">Chargement...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Modal Nouvelle Interaction -->
        <div class="modal fade" id="interactionModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Nouvelle Interaction</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="interactionForm">
                            <div class="form-group">
                                <label>Client *</label>
                                <select class="form-control" id="interaction-client" required>
                                    <option value="">Chargement...</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Type *</label>
                                <select class="form-control" id="interaction-type" required>
                                    ${CONFIG.INTERACTION_TYPES.map(t => `<option value="${t.value}">${t.label}</option>`).join('')}
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Date *</label>
                                <input type="datetime-local" class="form-control" id="interaction-date" required>
                            </div>
                            <div class="form-group">
                                <label>Sujet</label>
                                <input type="text" class="form-control" id="interaction-sujet">
                            </div>
                            <div class="form-group">
                                <label>Description</label>
                                <textarea class="form-control" id="interaction-description" rows="3"></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Annuler</button>
                        <button type="button" class="btn btn-primary" onclick="saveInteraction()">Enregistrer</button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    await refreshInteractions();
}

async function refreshInteractions(filters = {}) {
    try {
        showLoader();
        const response = await api.getInteractions(filters);
        displayInteractions(response.data || []);
        hideLoader();
    } catch (error) {
        hideLoader();
        showError('Erreur lors du chargement des interactions');
        console.error(error);
    }
}

function displayInteractions(interactions) {
    const tbody = document.getElementById('interactions-table-body');
    
    if (interactions.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center">Aucune interaction trouvée</td></tr>';
        return;
    }
    
    tbody.innerHTML = interactions.map(interaction => {
        const typeInfo = CONFIG.INTERACTION_TYPES.find(t => t.value === interaction.type);
        const typeLabel = typeInfo ? typeInfo.label : interaction.type;
        const typeIcon = typeInfo ? typeInfo.icon : 'comment';
        
        return `
            <tr>
                <td>${formatDate(interaction.date_interaction)}</td>
                <td>
                    <i class="fas fa-${typeIcon} mr-1"></i>
                    ${typeLabel}
                </td>
                <td>${interaction.sujet || '-'}</td>
                <td>${interaction.description ? interaction.description.substring(0, 50) + '...' : '-'}</td>
                <td>Client ID: ${interaction.client_id.substring(0, 8)}...</td>
            </tr>
        `;
    }).join('');
}

function filterInteractions() {
    const type = document.getElementById('filter-type').value;
    const filters = {};
    if (type) filters.type = type;
    refreshInteractions(filters);
}

async function showInteractionModal() {
    const modal = new bootstrap.Modal(document.getElementById('interactionModal'));
    
    // Charger la liste des clients
    try {
        const response = await api.getClients({ limit: 1000 });
        const clientSelect = document.getElementById('interaction-client');
        clientSelect.innerHTML = '<option value="">Sélectionner un client...</option>' +
            response.data.map(c => `<option value="${c.id}">${c.nom}</option>`).join('');
    } catch (error) {
        showError('Erreur lors du chargement des clients');
    }
    
    // Définir la date actuelle
    const now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    document.getElementById('interaction-date').value = now.toISOString().slice(0, 16);
    
    document.getElementById('interactionForm').reset();
    modal.show();
}

async function saveInteraction() {
    const data = {
        client_id: document.getElementById('interaction-client').value,
        type: document.getElementById('interaction-type').value,
        date_interaction: new Date(document.getElementById('interaction-date').value).toISOString(),
        sujet: document.getElementById('interaction-sujet').value || null,
        description: document.getElementById('interaction-description').value || null
    };
    
    if (!data.client_id || !data.type || !data.date_interaction) {
        showError('Veuillez remplir tous les champs obligatoires');
        return;
    }
    
    try {
        showLoader();
        await api.createInteraction(data);
        showSuccess('Interaction créée avec succès');
        bootstrap.Modal.getInstance(document.getElementById('interactionModal')).hide();
        await refreshInteractions();
        hideLoader();
    } catch (error) {
        hideLoader();
        showError(error.message || 'Erreur lors de l\'enregistrement');
    }
}
