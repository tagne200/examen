@echo off
REM Script de commit et push automatique

echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║     Git Commit - Validation C21                        ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

REM Vérifier Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Git n'est pas installe
    pause
    exit /b 1
)

echo [1/4] Ajout des fichiers...
git add .
echo [OK] Fichiers ajoutes
echo.

echo [2/4] Commit...
git commit -m "feat: add Docker deployment scripts for C21 validation - Add deploy.bat, validate-c21.bat, docker-compose.yml - Add comprehensive documentation - Add security scanning (Bandit, Safety) - Ready for C21 validation"
echo [OK] Commit cree
echo.

echo [3/4] Push vers GitHub...
git push origin main
if %errorlevel% neq 0 (
    echo [ERREUR] Echec du push
    echo Verifiez votre connexion et vos credentials
    pause
    exit /b 1
)
echo [OK] Push reussi
echo.

echo [4/4] Verification...
git status
echo.

echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║              PUSH TERMINE AVEC SUCCES !                ║
echo  ╚════════════════════════════════════════════════════════╝
echo.
echo  Fichiers pousses sur GitHub:
echo   • Scripts de deploiement (deploy.bat, validate-c21.bat)
echo   • Configuration Docker (docker-compose.yml, nginx.conf)
echo   • Documentation complete (guides, README)
echo   • Outils de securite (Bandit, Safety)
echo.
echo  Prochaines etapes:
echo   1. Verifier sur GitHub que tout est bien pousse
echo   2. Lancer deploy.bat pour deployer localement
echo   3. Prendre des screenshots
echo   4. Creer le rapport de validation
echo.
pause
