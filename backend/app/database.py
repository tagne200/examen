"""
Configuration de la base de données PostgreSQL
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import NullPool
import os
from dotenv import load_dotenv
from app.models import Base

load_dotenv()

# URL de connexion à la base de données
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL n'est pas définie dans les variables d'environnement")

# Créer le moteur SQLAlchemy
engine = create_engine(
    DATABASE_URL,
    poolclass=NullPool,  # Pour AWS Lambda
    echo=False,  # Mettre à True pour debug SQL
    pool_pre_ping=True  # Vérifier la connexion avant utilisation
)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db() -> Session:
    """
    Générateur de session de base de données
    À utiliser avec FastAPI Depends
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """
    Initialiser la base de données (créer les tables)
    """
    Base.metadata.create_all(bind=engine)
    print("✅ Base de données initialisée avec succès")

def drop_db():
    """
    Supprimer toutes les tables (ATTENTION: à utiliser avec précaution)
    """
    Base.metadata.drop_all(bind=engine)
    print("⚠️ Toutes les tables ont été supprimées")

if __name__ == "__main__":
    # Script pour initialiser la base de données
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "init":
            init_db()
        elif command == "drop":
            confirm = input("⚠️ Êtes-vous sûr de vouloir supprimer toutes les tables ? (oui/non): ")
            if confirm.lower() == "oui":
                drop_db()
            else:
                print("Opération annulée")
        else:
            print("Commande inconnue. Utilisez 'init' ou 'drop'")
    else:
        print("Usage: python -m app.database [init|drop]")
