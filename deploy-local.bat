@echo off
REM Script de déploiement local DIGITRANS-CM CRM
REM Valide la compétence C21.3 - Déployer l'infrastructure

echo ========================================
echo DIGITRANS-CM - Deploiement Local
echo ========================================
echo.

REM Vérifier Docker
echo [1/5] Verification de Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker n'est pas installe ou n'est pas dans le PATH
    echo Installez Docker Desktop depuis https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo [OK] Docker est installe
echo.

REM Vérifier Docker Compose
echo [2/5] Verification de Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Compose n'est pas installe
    pause
    exit /b 1
)
echo [OK] Docker Compose est installe
echo.

REM Arrêter les conteneurs existants
echo [3/5] Arret des conteneurs existants...
docker-compose down >nul 2>&1
echo [OK] Conteneurs arretes
echo.

REM Construire et démarrer les services
echo [4/5] Construction et demarrage des services...
echo Cela peut prendre quelques minutes...
docker-compose up -d --build

if %errorlevel% neq 0 (
    echo [ERREUR] Echec du demarrage des services
    pause
    exit /b 1
)
echo [OK] Services demarres
echo.

REM Attendre que les services soient prêts
echo [5/5] Attente du demarrage complet (30 secondes)...
timeout /t 30 /nobreak >nul
echo.

REM Vérifier l'état des services
echo ========================================
echo Etat des Services
echo ========================================
docker-compose ps
echo.

REM Tests de connectivité
echo ========================================
echo Tests de Connectivite
echo ========================================

echo [TEST 1] Frontend...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost/
echo.

echo [TEST 2] Backend Health Check...
curl -s http://localhost:8000/health
echo.
echo.

echo [TEST 3] Backend API Root...
curl -s http://localhost:8000/
echo.
echo.

echo ========================================
echo Deploiement Termine !
echo ========================================
echo.
echo URLs d'acces :
echo   - Frontend : http://localhost/
echo   - Backend  : http://localhost:8000/
echo   - API Docs : http://localhost:8000/docs
echo   - Health   : http://localhost:8000/health
echo.
echo Base de donnees PostgreSQL :
echo   - Host     : localhost
echo   - Port     : 5432
echo   - Database : crm_db
echo   - User     : admin
echo   - Password : SecurePassword123!
echo.
echo Redis Cache :
echo   - Host     : localhost
echo   - Port     : 6379
echo.
echo Commandes utiles :
echo   - Voir les logs       : docker-compose logs -f
echo   - Arreter les services: docker-compose down
echo   - Redemarrer          : docker-compose restart
echo.
echo Appuyez sur une touche pour ouvrir le navigateur...
pause >nul
start http://localhost/
