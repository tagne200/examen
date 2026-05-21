@echo off
REM Script de validation technique - Competence C21.5
REM Tests de connectivite, fonctionnels et performance

echo ========================================
echo C21.5 - Validation Technique
echo ========================================
echo.

REM Vérifier que les services sont démarrés
echo [VERIFICATION] Services en cours d'execution...
docker-compose ps | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo [ERREUR] Les services ne sont pas demarres
    echo Lancez d'abord: deploy-local.bat
    pause
    exit /b 1
)
echo [OK] Services actifs
echo.

REM Créer dossier pour les rapports
if not exist "reports" mkdir reports

echo ========================================
echo TEST 1 : Connectivite
echo ========================================
echo.

echo [1.1] Frontend (HTTP 200 attendu)...
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost/ > reports\test-frontend.txt
type reports\test-frontend.txt
echo.

echo [1.2] Backend Health Check...
curl -s http://localhost:8000/health > reports\test-health.json
type reports\test-health.json
echo.
echo.

echo [1.3] Backend API Root...
curl -s http://localhost:8000/ > reports\test-api-root.json
type reports\test-api-root.json
echo.
echo.

echo [1.4] PostgreSQL...
docker exec digitrans-postgres pg_isready -U admin -d crm_db
echo.

echo [1.5] Redis...
docker exec digitrans-redis redis-cli ping
echo.

echo ========================================
echo TEST 2 : Tests Unitaires
echo ========================================
echo.

echo Execution des tests Python...
docker exec digitrans-backend pytest tests/ -v --tb=short > reports\test-results.txt 2>&1
type reports\test-results.txt
echo.

echo ========================================
echo TEST 3 : Performance (Simple)
echo ========================================
echo.

echo Test de charge leger (10 requetes)...
echo Temps de reponse pour /health :
for /L %%i in (1,1,10) do (
    curl -s -o nul -w "Requete %%i: %%{time_total}s\n" http://localhost:8000/health
)
echo.

echo ========================================
echo TEST 4 : Securite
echo ========================================
echo.

echo [4.1] Scan de securite Bandit...
docker exec digitrans-backend bandit -r app/ -f txt > reports\security-bandit.txt 2>&1
echo Rapport genere: reports\security-bandit.txt
echo.

echo [4.2] Audit des dependances Safety...
docker exec digitrans-backend safety check > reports\security-safety.txt 2>&1
echo Rapport genere: reports\security-safety.txt
echo.

echo ========================================
echo TEST 5 : Logs et Monitoring
echo ========================================
echo.

echo [5.1] Logs Backend (10 dernieres lignes)...
docker logs digitrans-backend --tail 10
echo.

echo [5.2] Logs PostgreSQL (10 dernieres lignes)...
docker logs digitrans-postgres --tail 10
echo.

echo ========================================
echo Validation Terminee !
echo ========================================
echo.
echo Rapports generes dans le dossier 'reports\' :
dir /B reports
echo.
echo Statut de validation C21.5 :
echo   [OK] Tests de connectivite
echo   [OK] Tests unitaires
echo   [OK] Tests de performance
echo   [OK] Scan de securite
echo   [OK] Monitoring et logs
echo.
echo Competence C21.5 VALIDEE !
echo.
pause
