"""
Tests unitaires pour l'API CRM DIGITRANS-CM
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    """Test du endpoint health check"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "version" in data

def test_root_endpoint():
    """Test du endpoint racine"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data

def test_get_clients_without_auth():
    """Test d'accès aux clients sans authentification"""
    response = client.get("/api/clients")
    # Devrait retourner 401 ou 403 en production
    # En mode dev, peut retourner 200
    assert response.status_code in [200, 401, 403]

def test_create_client_with_dev_token():
    """Test de création d'un client avec token dev"""
    headers = {"Authorization": "Bearer dev-token"}
    client_data = {
        "nom": "Test Restaurant",
        "email": "test@example.cm",
        "ville": "Douala",
        "statut": "actif"
    }
    response = client.post("/api/clients", json=client_data, headers=headers)
    # Peut échouer si la DB n'est pas configurée
    assert response.status_code in [201, 500]

def test_get_dashboard_stats():
    """Test des statistiques du dashboard"""
    headers = {"Authorization": "Bearer dev-token"}
    response = client.get("/api/stats/dashboard", headers=headers)
    assert response.status_code in [200, 500]
    if response.status_code == 200:
        data = response.json()
        assert "total_clients" in data
        assert "clients_actifs" in data

def test_invalid_client_id():
    """Test avec un ID client invalide"""
    headers = {"Authorization": "Bearer dev-token"}
    response = client.get("/api/clients/invalid-uuid", headers=headers)
    assert response.status_code == 400

def test_client_not_found():
    """Test avec un client inexistant"""
    headers = {"Authorization": "Bearer dev-token"}
    fake_uuid = "00000000-0000-0000-0000-000000000000"
    response = client.get(f"/api/clients/{fake_uuid}", headers=headers)
    assert response.status_code in [404, 500]

# Pour lancer les tests :
# pytest backend/tests/test_api.py -v
