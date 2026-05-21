"""
Point d'entrée principal de l'API CRM DIGITRANS-CM
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import os
from dotenv import load_dotenv

# Charger les variables d'environnement
load_dotenv()

# Import des routes
from app.routes import router

# Créer l'application FastAPI
app = FastAPI(
    title="DIGITRANS-CM CRM API",
    description="API REST pour la gestion de la relation client - AGROCAM S.A.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configuration CORS
origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclure les routes
app.include_router(router, prefix="/api")

# Health check endpoint
@app.get("/health")
async def health_check():
    """Endpoint de vérification de santé de l'API"""
    return {
        "status": "healthy",
        "service": "DIGITRANS-CM CRM API",
        "version": "1.0.0"
    }

# Root endpoint
@app.get("/")
async def root():
    """Endpoint racine"""
    return {
        "message": "DIGITRANS-CM CRM API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

# Gestionnaire d'erreurs global
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Gestionnaire d'erreurs global"""
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "message": str(exc),
            "path": str(request.url)
        }
    )

# Pour AWS Lambda (optionnel)
def handler(event, context):
    """Handler pour AWS Lambda avec Mangum"""
    from mangum import Mangum
    asgi_handler = Mangum(app)
    return asgi_handler(event, context)

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("API_PORT", 8000))
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        reload=True
    )
