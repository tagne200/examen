@echo off
REM Script de vérification des prérequis pour le déploiement

title Verification des Prerequis
color 0B

echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║        VERIFICATION DES PREREQUIS                     ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

set "ALL_OK=1"

REM Vérifier Docker
echo  [1/5] Docker Desktop...
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Docker est installe
    docker --version
) else (
    echo   [X] Docker n'est PAS installe
    echo       Telechargez: https://www.docker.com/products/docker-desktop
    set "ALL_OK=0"
)
echo.

REM Vérifier Docker Compose
echo  [2/5] Docker Compose...
docker-compose --version >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Docker Compose est installe
    docker-compose --version
) else (
    echo   [X] Docker Compose n'est PAS installe
    set "ALL_OK=0"
)
echo.

REM Vérifier que Docker est démarré
echo  [3/5] Docker Daemon (service)...
docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Docker est demarre et fonctionne
) else (
    echo   [X] Docker n'est PAS demarre
    echo       Demarrez Docker Desktop
    set "ALL_OK=0"
)
echo.

REM Vérifier curl
echo  [4/5] Curl (pour les tests)...
curl --version >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] Curl est disponible
) else (
    echo   [!] Curl n'est pas disponible (optionnel)
    echo       Les tests de connectivite ne fonctionneront pas
)
echo.

REM Vérifier l'espace disque
echo  [5/5] Espace disque...
for /f "tokens=3" %%a in ('dir /-c ^| find "bytes free"') do set FREE_SPACE=%%a
echo   [INFO] Espace libre: %FREE_SPACE% bytes
echo   [INFO] Minimum requis: 5 GB
echo.

REM Résumé
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║                    RESUME                              ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

if "%ALL_OK%"=="1" (
    color 0A
    echo   [OK] Tous les prerequis sont satisfaits !
    echo.
    echo   Vous pouvez lancer le deploiement:
    echo     deploy.bat
    echo.
) else (
    color 0C
    echo   [X] Certains prerequis manquent
    echo.
    echo   Actions requises:
    echo   1. Installer Docker Desktop
    echo   2. Demarrer Docker Desktop
    echo   3. Relancer ce script
    echo.
)

echo  ────────────────────────────────────────────────────────
echo  Informations systeme:
echo   • OS: %OS%
echo   • Utilisateur: %USERNAME%
echo   • Repertoire: %CD%
echo  ────────────────────────────────────────────────────────
echo.

pause
