/**
 * Page Gestion des Clients
 */

let currentClients = [];

async function loadClients() {
    const content = document.getElementById('main-content');
    
    content.innerHTML = `
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Liste des Clients</h3>
                <div class="card-tools">
                    <button type="button" class="btn btn-primary btn-sm" onclick="showClientModal()">
                        <i class="fas fa-plus"></i> Nouveau Client
                    </button>
                </div>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-4">
                        <input type="text" class="form-control" id="search-clients" placeholder="Rechercher...">
                    </div>
                    <div class="col-md-3">
                        <select class="form-control" id="filter-ville">
                            <option value="">Toutes les villes</option>
                            ${CONFIG.CITIES.map(city => `<option value="${city}">${city}</option>`).join('')}
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select class="form-control" id="filter-statut">
                            <option value="">Tous les statuts</option>
                            ${CONFIG.CLIENT_STATUS.map(s => `<option value="${s.value}">${s.label}</option>`).join('')}
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button class="btn btn-info btn-block" onclick="filterClients()">
                            <i class="fas fa-filter"></i> Filtrer
                        </button>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr>
                                <th>Nom</th>
                                <th>Email</th>
                                <th>Téléphone</th>
                                <th>Ville</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="clients-table-body">
                            <tr><td colspan="6" class="text-center">Chargement...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Modal Nouveau/Modifier Client -->
        <div class="modal fade" id="clientModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="clientModalTitle">Nouveau Client</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="clientForm">
                            <input type="hidden" id="client-id">
                            <div class="form-group">
                                <label>Nom *</label>
                                <input type="text" class="form-control" id="client-nom" required>
                            </div>
                            <div class="form-group">
                                <label>Email</label>
                                <input type="email" class="form-control" id="client-email">
                            </div>
                            <div class="form-group">
                                <label>Téléphone</label>
                                <input type="tel" class="form-control" id="client-telephone">
                            </div>
                            <div class="form-group">
                                <label>Adresse</label>
                                <textarea class="form-control" id="client-adresse" rows="2"></textarea>
                            </div>
                            <div class="form-group">
                                <label>Ville</label>
                                <select class="form-control" id="client-ville">
                                    <option value="">Sélectionner...</option>
                                    ${CONFIG.CITIES.map(city => `<option value="${city}">${city}</option>`).join('')}
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Statut</label>
                                <select class="form-control" id="client-statut">
                                    ${CONFIG.CLIENT_STATUS.map(s => `<option value="${s.value}">${s.label}</option>`).join('')}
                                </select>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Annuler</button>
                        <button type="button" class="btn btn-primary" onclick="saveClient()">Enregistrer</button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Charger les clients
    await refreshClients();
}

async function refreshClients(filters = {}) {
    try {
        showLoader();
        const response = await api.getClients(filters);
        currentClients = response.data || [];
        displayClients(currentClients);
        hideLoader();
    } catch (error) {
        hideLoader();
        showError('Erreur lors du chargement des clients');
        console.error(error);
    }
}

function displayClients(clients) {
    const tbody = document.getElementById('clients-table-body');
    
    if (clients.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="text-center">Aucun client trouvé</td></tr>';
        return;
    }
    
    tbody.innerHTML = clients.map(client => {
        const statusClass = CONFIG.CLIENT_STATUS.find(s => s.value === client.statut)?.class || 'secondary';
        return `
            <tr>
                <td>${client.nom}</td>
                <td>${client.email || '-'}</td>
                <td>${client.telephone || '-'}</td>
                <td>${client.ville || '-'}</td>
                <td><span class="badge badge-${statusClass}">${client.statut}</span></td>
                <td>
                    <button class="btn btn-sm btn-info" onclick="viewClient('${client.id}')" title="Voir">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-warning" onclick="editClient('${client.id}')" title="Modifier">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="deleteClientConfirm('${client.id}')" title="Supprimer">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    }).join('');
}

function filterClients() {
    const search = document.getElementById('search-clients').value;
    const ville = document.getElementById('filter-ville').value;
    const statut = document.getElementById('filter-statut').value;
    
    const filters = {};
    if (search) filters.search = search;
    if (ville) filters.ville = ville;
    if (statut) filters.statut = statut;
    
    refreshClients(filters);
}

function showClientModal(clientId = null) {
    const modal = new bootstrap.Modal(document.getElementById('clientModal'));
    
    if (clientId) {
        document.getElementById('clientModalTitle').textContent = 'Modifier Client';
        const client = currentClients.find(c => c.id === clientId);
        if (client) {
            document.getElementById('client-id').value = client.id;
            document.getElementById('client-nom').value = client.nom;
            document.getElementById('client-email').value = client.email || '';
            document.getElementById('client-telephone').value = client.telephone || '';
            document.getElementById('client-adresse').value = client.adresse || '';
            document.getElementById('client-ville').value = client.ville || '';
            document.getElementById('client-statut').value = client.statut;
        }
    } else {
        document.getElementById('clientModalTitle').textContent = 'Nouveau Client';
        document.getElementById('clientForm').reset();
        document.getElementById('client-id').value = '';
    }
    
    modal.show();
}

async function saveClient() {
    const clientId = document.getElementById('client-id').value;
    const data = {
        nom: document.getElementById('client-nom').value,
        email: document.getElementById('client-email').value || null,
        telephone: document.getElementById('client-telephone').value || null,
        adresse: document.getElementById('client-adresse').value || null,
        ville: document.getElementById('client-ville').value || null,
        statut: document.getElementById('client-statut').value
    };
    
    if (!data.nom) {
        showError('Le nom est obligatoire');
        return;
    }
    
    try {
        showLoader();
        if (clientId) {
            await api.updateClient(clientId, data);
            showSuccess('Client modifié avec succès');
        } else {
            await api.createClient(data);
            showSuccess('Client créé avec succès');
        }
        
        bootstrap.Modal.getInstance(document.getElementById('clientModal')).hide();
        await refreshClients();
        hideLoader();
    } catch (error) {
        hideLoader();
        showError(error.message || 'Erreur lors de l\'enregistrement');
    }
}

function editClient(clientId) {
    showClientModal(clientId);
}

async function deleteClientConfirm(clientId) {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce client ?')) {
        return;
    }
    
    try {
        showLoader();
        await api.deleteClient(clientId);
        showSuccess('Client supprimé avec succès');
        await refreshClients();
        hideLoader();
    } catch (error) {
        hideLoader();
        showError(error.message || 'Erreur lors de la suppression');
    }
}

async function viewClient(clientId) {
    try {
        showLoader();
        const response = await api.getClient(clientId);
        const client = response.data;
        hideLoader();
        
        alert(`Détails du client:\n\nNom: ${client.nom}\nEmail: ${client.email || '-'}\nTéléphone: ${client.telephone || '-'}\nVille: ${client.ville || '-'}\nStatut: ${client.statut}`);
    } catch (error) {
        hideLoader();
        showError('Erreur lors du chargement des détails');
    }
}
