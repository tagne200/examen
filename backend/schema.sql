-- Script SQL pour initialiser la base de données CRM DIGITRANS-CM
-- PostgreSQL 15+

-- Activer l'extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table clients
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    telephone VARCHAR(20),
    adresse TEXT,
    ville VARCHAR(100),
    statut VARCHAR(50) DEFAULT 'actif',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);
CREATE INDEX IF NOT EXISTS idx_clients_ville ON clients(ville);
CREATE INDEX IF NOT EXISTS idx_clients_statut ON clients(statut);

-- Table contacts
CREATE TABLE IF NOT EXISTS contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255),
    fonction VARCHAR(100),
    email VARCHAR(255),
    telephone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index pour les contacts
CREATE INDEX IF NOT EXISTS idx_contacts_client_id ON contacts(client_id);
CREATE INDEX IF NOT EXISTS idx_contacts_email ON contacts(email);

-- Table interactions
CREATE TABLE IF NOT EXISTS interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('appel', 'email', 'visite', 'reunion')),
    sujet VARCHAR(255),
    description TEXT,
    date_interaction TIMESTAMP NOT NULL,
    user_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index pour les interactions
CREATE INDEX IF NOT EXISTS idx_interactions_client_id ON interactions(client_id);
CREATE INDEX IF NOT EXISTS idx_interactions_type ON interactions(type);
CREATE INDEX IF NOT EXISTS idx_interactions_date ON interactions(date_interaction DESC);
CREATE INDEX IF NOT EXISTS idx_interactions_user_id ON interactions(user_id);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour la table clients
DROP TRIGGER IF EXISTS update_clients_updated_at ON clients;
CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Données de test (optionnel)
INSERT INTO clients (nom, email, telephone, ville, statut) VALUES
    ('Restaurant Le Palmier', 'contact@lepalmier.cm', '+237 699 123 456', 'Douala', 'actif'),
    ('Hôtel Akwa Palace', 'info@akwapalace.cm', '+237 699 234 567', 'Douala', 'actif'),
    ('Café des Arts', 'cafe@arts.cm', '+237 699 345 678', 'Yaoundé', 'actif'),
    ('Boulangerie Moderne', 'contact@boulangerie.cm', '+237 699 456 789', 'Bafoussam', 'prospect')
ON CONFLICT (email) DO NOTHING;

-- Vérification
SELECT 'Tables créées avec succès!' AS message;
SELECT COUNT(*) AS nombre_clients FROM clients;
SELECT COUNT(*) AS nombre_contacts FROM contacts;
SELECT COUNT(*) AS nombre_interactions FROM interactions;

-- Pour exécuter ce script :
-- psql -h <host> -U <user> -d <database> -f schema.sql
