"""
Routes API pour le module CRM
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr
import uuid

from app.database import get_db
from app.models import Client, Contact, Interaction
from app.auth import get_current_user_dev as get_current_user  # Utiliser get_current_user en prod

router = APIRouter()

# ============= SCHEMAS PYDANTIC =============

class ClientCreate(BaseModel):
    nom: str
    email: Optional[EmailStr] = None
    telephone: Optional[str] = None
    adresse: Optional[str] = None
    ville: Optional[str] = None
    statut: str = "actif"

class ClientUpdate(BaseModel):
    nom: Optional[str] = None
    email: Optional[EmailStr] = None
    telephone: Optional[str] = None
    adresse: Optional[str] = None
    ville: Optional[str] = None
    statut: Optional[str] = None

class ContactCreate(BaseModel):
    client_id: str
    nom: str
    prenom: Optional[str] = None
    fonction: Optional[str] = None
    email: Optional[EmailStr] = None
    telephone: Optional[str] = None

class InteractionCreate(BaseModel):
    client_id: str
    type: str  # appel, email, visite, reunion
    sujet: Optional[str] = None
    description: Optional[str] = None
    date_interaction: datetime

# ============= ENDPOINTS CLIENTS =============

@router.get("/clients", tags=["Clients"])
async def get_clients(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    search: Optional[str] = None,
    ville: Optional[str] = None,
    statut: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer la liste des clients avec filtres et pagination
    """
    query = db.query(Client)
    
    # Filtres
    if search:
        query = query.filter(
            (Client.nom.ilike(f"%{search}%")) |
            (Client.email.ilike(f"%{search}%"))
        )
    if ville:
        query = query.filter(Client.ville == ville)
    if statut:
        query = query.filter(Client.statut == statut)
    
    # Pagination
    total = query.count()
    clients = query.offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "skip": skip,
        "limit": limit,
        "data": [client.to_dict() for client in clients]
    }

@router.post("/clients", tags=["Clients"], status_code=201)
async def create_client(
    client_data: ClientCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Créer un nouveau client
    """
    # Vérifier si l'email existe déjà
    if client_data.email:
        existing = db.query(Client).filter(Client.email == client_data.email).first()
        if existing:
            raise HTTPException(status_code=400, detail="Un client avec cet email existe déjà")
    
    # Créer le client
    client = Client(**client_data.dict())
    db.add(client)
    db.commit()
    db.refresh(client)
    
    return {
        "message": "Client créé avec succès",
        "data": client.to_dict()
    }

@router.get("/clients/{client_id}", tags=["Clients"])
async def get_client(
    client_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer les détails d'un client
    """
    try:
        client_uuid = uuid.UUID(client_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID client invalide")
    
    client = db.query(Client).filter(Client.id == client_uuid).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    # Inclure les contacts et interactions
    data = client.to_dict()
    data["contacts"] = [contact.to_dict() for contact in client.contacts]
    data["interactions"] = [interaction.to_dict() for interaction in client.interactions]
    
    return {"data": data}

@router.put("/clients/{client_id}", tags=["Clients"])
async def update_client(
    client_id: str,
    client_data: ClientUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Mettre à jour un client
    """
    try:
        client_uuid = uuid.UUID(client_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID client invalide")
    
    client = db.query(Client).filter(Client.id == client_uuid).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    # Mettre à jour les champs fournis
    update_data = client_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(client, field, value)
    
    client.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(client)
    
    return {
        "message": "Client mis à jour avec succès",
        "data": client.to_dict()
    }

@router.delete("/clients/{client_id}", tags=["Clients"])
async def delete_client(
    client_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Supprimer un client (et ses contacts/interactions en cascade)
    """
    try:
        client_uuid = uuid.UUID(client_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID client invalide")
    
    client = db.query(Client).filter(Client.id == client_uuid).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    db.delete(client)
    db.commit()
    
    return {"message": "Client supprimé avec succès"}

# ============= ENDPOINTS CONTACTS =============

@router.get("/clients/{client_id}/contacts", tags=["Contacts"])
async def get_client_contacts(
    client_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer tous les contacts d'un client
    """
    try:
        client_uuid = uuid.UUID(client_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID client invalide")
    
    contacts = db.query(Contact).filter(Contact.client_id == client_uuid).all()
    
    return {
        "total": len(contacts),
        "data": [contact.to_dict() for contact in contacts]
    }

@router.post("/contacts", tags=["Contacts"], status_code=201)
async def create_contact(
    contact_data: ContactCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Créer un nouveau contact
    """
    # Vérifier que le client existe
    try:
        client_uuid = uuid.UUID(contact_data.client_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID client invalide")
    
    client = db.query(Client).filter(Client.id == client_uuid).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    # Créer le contact
    contact = Contact(**contact_data.dict())
    db.add(contact)
    db.commit()
    db.refresh(contact)
    
    return {
        "message": "Contact créé avec succès",
        "data": contact.to_dict()
    }

@router.get("/contacts/{contact_id}", tags=["Contacts"])
async def get_contact(
    contact_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer les détails d'un contact
    """
    try:
        contact_uuid = uuid.UUID(contact_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID contact invalide")
    
    contact = db.query(Contact).filter(Contact.id == contact_uuid).first()
    if not contact:
        raise HTTPException(status_code=404, detail="Contact non trouvé")
    
    return {"data": contact.to_dict()}

@router.delete("/contacts/{contact_id}", tags=["Contacts"])
async def delete_contact(
    contact_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Supprimer un contact
    """
    try:
        contact_uuid = uuid.UUID(contact_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID contact invalide")
    
    contact = db.query(Contact).filter(Contact.id == contact_uuid).first()
    if not contact:
        raise HTTPException(status_code=404, detail="Contact non trouvé")
    
    db.delete(contact)
    db.commit()
    
    return {"message": "Contact supprimé avec succès"}

# ============= ENDPOINTS INTERACTIONS =============

@router.get("/interactions", tags=["Interactions"])
async def get_interactions(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    client_id: Optional[str] = None,
    type: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer la liste des interactions avec filtres
    """
    query = db.query(Interaction)
    
    # Filtres
    if client_id:
        try:
            client_uuid = uuid.UUID(client_id)
            query = query.filter(Interaction.client_id == client_uuid)
        except ValueError:
            raise HTTPException(status_code=400, detail="ID client invalide")
    
    if type:
        query = query.filter(Interaction.type == type)
    
    # Tri par date décroissante
    query = query.order_by(Interaction.date_interaction.desc())
    
    # Pagination
    total = query.count()
    interactions = query.offset(skip).limit(limit).all()
    
    return {
        "total": total,
        "skip": skip,
        "limit": limit,
        "data": [interaction.to_dict() for interaction in interactions]
    }

@router.post("/interactions", tags=["Interactions"], status_code=201)
async def create_interaction(
    interaction_data: InteractionCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Créer une nouvelle interaction
    """
    # Vérifier que le client existe
    try:
        client_uuid = uuid.UUID(interaction_data.client_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID client invalide")
    
    client = db.query(Client).filter(Client.id == client_uuid).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client non trouvé")
    
    # Créer l'interaction
    interaction = Interaction(**interaction_data.dict())
    interaction.user_id = current_user.get("sub")  # ID Azure AD
    db.add(interaction)
    db.commit()
    db.refresh(interaction)
    
    return {
        "message": "Interaction créée avec succès",
        "data": interaction.to_dict()
    }

@router.get("/interactions/{interaction_id}", tags=["Interactions"])
async def get_interaction(
    interaction_id: str,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer les détails d'une interaction
    """
    try:
        interaction_uuid = uuid.UUID(interaction_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="ID interaction invalide")
    
    interaction = db.query(Interaction).filter(Interaction.id == interaction_uuid).first()
    if not interaction:
        raise HTTPException(status_code=404, detail="Interaction non trouvée")
    
    return {"data": interaction.to_dict()}

# ============= ENDPOINTS STATISTIQUES =============

@router.get("/stats/dashboard", tags=["Statistiques"])
async def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Récupérer les statistiques pour le tableau de bord
    """
    total_clients = db.query(Client).count()
    clients_actifs = db.query(Client).filter(Client.statut == "actif").count()
    total_interactions = db.query(Interaction).count()
    
    # Interactions par type
    interactions_by_type = {}
    for type_name in ["appel", "email", "visite", "reunion"]:
        count = db.query(Interaction).filter(Interaction.type == type_name).count()
        interactions_by_type[type_name] = count
    
    return {
        "total_clients": total_clients,
        "clients_actifs": clients_actifs,
        "total_interactions": total_interactions,
        "interactions_by_type": interactions_by_type
    }
