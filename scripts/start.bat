@echo off
REM Script de démarrage rapide pour DIGITRANS-CM CRM
REM Windows

echo ========================================
echo DIGITRANS-CM CRM - Demarrage
echo ========================================
echo.

REM Vérifier si Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe ou n'est pas dans le PATH
    echo Telechargez Python depuis https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [OK] Python detecte
echo.

REM Aller dans le dossier backend
cd backend

REM Vérifier si l'environnement virtuel existe
if not exist "venv" (
    echo Creation de l'environnement virtuel...
    python -m venv venv
    echo [OK] Environnement virtuel cree
    echo.
)

REM Activer l'environnement virtuel
echo Activation de l'environnement virtuel...
call venv\Scripts\activate.bat

REM Installer les dépendances
echo Installation des dependances...
pip install -r requirements.txt --quiet
echo [OK] Dependances installees
echo.

REM Vérifier si le fichier .env existe
if not exist ".env" (
    echo [ATTENTION] Fichier .env non trouve
    echo Copie de .env.example vers .env...
    copy .env.example .env
    echo.
    echo [ACTION REQUISE] Editez le fichier backend\.env avec vos credentials
    echo Appuyez sur une touche pour continuer quand c'est fait...
    pause
)

REM Initialiser la base de données
echo Initialisation de la base de donnees...
python -m app.database init
echo.

REM Démarrer le serveur
echo ========================================
echo Demarrage du serveur API...
echo ========================================
echo.
echo API disponible sur: http://localhost:8000
echo Documentation: http://localhost:8000/docs
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

pause
