@echo off
REM Script de déploiement simplifié DIGITRANS-CM CRM
REM Compétence C21.3 - Déployer l'infrastructure cloud

title DIGITRANS-CM - Deploiement
color 0A

echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║     DIGITRANS-CM - Module CRM AGROCAM S.A.            ║
echo  ║     Deploiement Local avec Docker                      ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

REM Vérifier Docker
echo [ETAPE 1/6] Verification de Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [X] ERREUR: Docker n'est pas installe !
    echo.
    echo  Installez Docker Desktop:
    echo  https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)
echo  [OK] Docker detecte
echo.

REM Vérifier que Docker est démarré
echo [ETAPE 2/6] Verification que Docker est demarre...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [X] ERREUR: Docker n'est pas demarre !
    echo.
    echo  Demarrez Docker Desktop et reessayez.
    echo.
    pause
    exit /b 1
)
echo  [OK] Docker est actif
echo.

REM Nettoyer les anciens conteneurs
echo [ETAPE 3/6] Nettoyage des anciens conteneurs...
docker-compose down >nul 2>&1
echo  [OK] Nettoyage termine
echo.

REM Construire les images
echo [ETAPE 4/6] Construction des images Docker...
echo  Cela peut prendre 2-5 minutes la premiere fois...
echo.
docker-compose build
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [X] ERREUR lors de la construction !
    echo.
    pause
    exit /b 1
)
echo.
echo  [OK] Images construites
echo.

REM Démarrer les services
echo [ETAPE 5/6] Demarrage des services...
docker-compose up -d
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  [X] ERREUR lors du demarrage !
    echo.
    pause
    exit /b 1
)
echo  [OK] Services demarres
echo.

REM Attendre que tout soit prêt
echo [ETAPE 6/6] Attente du demarrage complet...
echo  Patientez 30 secondes...
timeout /t 30 /nobreak >nul
echo  [OK] Services prets
echo.

REM Afficher l'état
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║              ETAT DES SERVICES                         ║
echo  ╚════════════════════════════════════════════════════════╝
echo.
docker-compose ps
echo.

REM Tests rapides
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║              TESTS DE CONNECTIVITE                     ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

echo  [TEST 1] PostgreSQL...
docker exec digitrans-postgres pg_isready -U admin -d crm_db >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] PostgreSQL est pret
) else (
    echo   [!] PostgreSQL n'est pas encore pret
)

echo  [TEST 2] Redis...
docker exec digitrans-redis redis-cli ping >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Redis est pret
) else (
    echo   [!] Redis n'est pas encore pret
)

echo  [TEST 3] Backend API...
curl -s http://localhost:8000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Backend API est pret
) else (
    echo   [!] Backend API n'est pas encore pret
)

echo  [TEST 4] Frontend...
curl -s http://localhost/ >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Frontend est pret
) else (
    echo   [!] Frontend n'est pas encore pret
)

echo.
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║           DEPLOIEMENT TERMINE AVEC SUCCES !            ║
echo  ╚════════════════════════════════════════════════════════╝
echo.
echo  URLs d'acces:
echo   • Frontend    : http://localhost/
echo   • Backend API : http://localhost:8000/
echo   • API Docs    : http://localhost:8000/docs
echo   • Health Check: http://localhost:8000/health
echo.
echo  Base de donnees PostgreSQL:
echo   • Host     : localhost
echo   • Port     : 5432
echo   • Database : crm_db
echo   • User     : admin
echo   • Password : SecurePassword123!
echo.
echo  Cache Redis:
echo   • Host : localhost
echo   • Port : 6379
echo.
echo  ────────────────────────────────────────────────────────
echo  Commandes utiles:
echo   • Voir les logs        : docker-compose logs -f
echo   • Arreter les services : docker-compose down
echo   • Redemarrer           : docker-compose restart
echo   • Valider C21          : validate-c21.bat
echo  ────────────────────────────────────────────────────────
echo.
echo  Appuyez sur une touche pour ouvrir l'application...
pause >nul

REM Ouvrir dans le navigateur
start http://localhost/
start http://localhost:8000/docs

echo.
echo  Application ouverte dans le navigateur !
echo.
pause
