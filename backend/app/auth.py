"""
Authentification Azure AD avec validation de tokens JWT
"""
from fastapi import HTTPException, Security, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt, JWTError
import os
import httpx
from functools import lru_cache
from dotenv import load_dotenv

load_dotenv()

# Configuration Azure AD
AZURE_TENANT_ID = os.getenv("AZURE_TENANT_ID")
AZURE_CLIENT_ID = os.getenv("AZURE_CLIENT_ID")

if not AZURE_TENANT_ID or not AZURE_CLIENT_ID:
    raise ValueError("AZURE_TENANT_ID et AZURE_CLIENT_ID doivent être définis")

# URL des métadonnées OpenID Connect
OPENID_CONFIG_URL = f"https://login.microsoftonline.com/{AZURE_TENANT_ID}/v2.0/.well-known/openid-configuration"
JWKS_URL = f"https://login.microsoftonline.com/{AZURE_TENANT_ID}/discovery/v2.0/keys"

# Security scheme
security = HTTPBearer()

@lru_cache()
def get_jwks():
    """
    Récupérer les clés publiques de signature JWT (avec cache)
    """
    try:
        response = httpx.get(JWKS_URL, timeout=10)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"❌ Erreur lors de la récupération des JWKS: {e}")
        return None

def verify_token(token: str) -> dict:
    """
    Vérifier et décoder un token JWT Azure AD
    
    Args:
        token: Token JWT à vérifier
        
    Returns:
        dict: Payload du token décodé
        
    Raises:
        HTTPException: Si le token est invalide
    """
    try:
        # Récupérer les clés publiques
        jwks = get_jwks()
        if not jwks:
            raise HTTPException(
                status_code=500,
                detail="Impossible de récupérer les clés de signature"
            )
        
        # Décoder le header pour obtenir le kid (key ID)
        unverified_header = jwt.get_unverified_header(token)
        kid = unverified_header.get("kid")
        
        # Trouver la clé correspondante
        key = None
        for jwk in jwks.get("keys", []):
            if jwk.get("kid") == kid:
                key = jwk
                break
        
        if not key:
            raise HTTPException(
                status_code=401,
                detail="Clé de signature non trouvée"
            )
        
        # Vérifier et décoder le token
        payload = jwt.decode(
            token,
            key,
            algorithms=["RS256"],
            audience=AZURE_CLIENT_ID,
            issuer=f"https://login.microsoftonline.com/{AZURE_TENANT_ID}/v2.0"
        )
        
        return payload
        
    except JWTError as e:
        raise HTTPException(
            status_code=401,
            detail=f"Token invalide: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=401,
            detail=f"Erreur d'authentification: {str(e)}"
        )

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> dict:
    """
    Dépendance FastAPI pour obtenir l'utilisateur courant
    
    Args:
        credentials: Credentials HTTP Bearer
        
    Returns:
        dict: Informations de l'utilisateur (payload du token)
    """
    token = credentials.credentials
    user = verify_token(token)
    return user

# Fonction simplifiée pour le développement (à retirer en production)
async def get_current_user_dev(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> dict:
    """
    Version simplifiée pour le développement (sans validation réelle)
    ⚠️ À UTILISER UNIQUEMENT EN DÉVELOPPEMENT
    """
    return {
        "sub": "dev-user-id",
        "name": "Développeur Test",
        "email": "dev@camtech.cm",
        "roles": ["admin"]
    }

# Fonction pour vérifier les rôles
def require_role(required_role: str):
    """
    Décorateur pour vérifier qu'un utilisateur a un rôle spécifique
    
    Args:
        required_role: Rôle requis (admin, manager, agent)
    """
    async def role_checker(user: dict = Depends(get_current_user)):
        user_roles = user.get("roles", [])
        if required_role not in user_roles and "admin" not in user_roles:
            raise HTTPException(
                status_code=403,
                detail=f"Rôle '{required_role}' requis"
            )
        return user
    return role_checker
