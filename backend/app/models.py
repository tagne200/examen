"""
Modèles de données SQLAlchemy pour le CRM
"""
from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import uuid

Base = declarative_base()

class Client(Base):
    """Modèle Client"""
    __tablename__ = "clients"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nom = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, index=True)
    telephone = Column(String(20))
    adresse = Column(Text)
    ville = Column(String(100))
    statut = Column(String(50), default="actif")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    contacts = relationship("Contact", back_populates="client", cascade="all, delete-orphan")
    interactions = relationship("Interaction", back_populates="client", cascade="all, delete-orphan")
    
    def to_dict(self):
        """Convertir en dictionnaire"""
        return {
            "id": str(self.id),
            "nom": self.nom,
            "email": self.email,
            "telephone": self.telephone,
            "adresse": self.adresse,
            "ville": self.ville,
            "statut": self.statut,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None
        }

class Contact(Base):
    """Modèle Contact"""
    __tablename__ = "contacts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    nom = Column(String(255), nullable=False)
    prenom = Column(String(255))
    fonction = Column(String(100))
    email = Column(String(255))
    telephone = Column(String(20))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relations
    client = relationship("Client", back_populates="contacts")
    
    def to_dict(self):
        """Convertir en dictionnaire"""
        return {
            "id": str(self.id),
            "client_id": str(self.client_id),
            "nom": self.nom,
            "prenom": self.prenom,
            "fonction": self.fonction,
            "email": self.email,
            "telephone": self.telephone,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }

class Interaction(Base):
    """Modèle Interaction"""
    __tablename__ = "interactions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    type = Column(String(50), nullable=False)  # appel, email, visite, reunion
    sujet = Column(String(255))
    description = Column(Text)
    date_interaction = Column(DateTime, nullable=False)
    user_id = Column(String(255))  # ID Azure AD de l'utilisateur
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relations
    client = relationship("Client", back_populates="interactions")
    
    def to_dict(self):
        """Convertir en dictionnaire"""
        return {
            "id": str(self.id),
            "client_id": str(self.client_id),
            "type": self.type,
            "sujet": self.sujet,
            "description": self.description,
            "date_interaction": self.date_interaction.isoformat() if self.date_interaction else None,
            "user_id": self.user_id,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }
