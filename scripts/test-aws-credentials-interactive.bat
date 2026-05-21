@echo off
echo ========================================
echo Test AWS Credentials
echo ========================================
echo.

REM Vérifier si AWS CLI est installé
where aws >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] AWS CLI n'est pas installé
    echo Installer depuis: https://aws.amazon.com/cli/
    pause
    exit /b 1
)

echo [OK] AWS CLI installé
echo.

REM Demander les credentials
set /p AWS_ACCESS_KEY="Entrez AWS_ACCESS_KEY_ID: "
set /p AWS_SECRET_KEY="Entrez AWS_SECRET_ACCESS_KEY: "
set /p AWS_REGION="Entrez AWS_REGION (af-south-1): "

if "%AWS_REGION%"=="" set AWS_REGION=af-south-1

echo.
echo Test des credentials...
echo.

REM Configurer temporairement
set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_KEY%
set AWS_DEFAULT_REGION=%AWS_REGION%

REM Test 1: Get Caller Identity
echo [TEST 1] Verification identite...
aws sts get-caller-identity
if %ERRORLEVEL% EQU 0 (
    echo [OK] Credentials valides
) else (
    echo [ERREUR] Credentials invalides
    echo.
    echo Causes possibles:
    echo - Access Key incorrecte
    echo - Secret Key incorrecte
    echo - Credentials expirées
    echo - Utilisateur IAM supprimé
    pause
    exit /b 1
)

echo.
echo [TEST 2] Verification permissions ECR...
aws ecr describe-repositories --region %AWS_REGION% 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Acces ECR autorise
) else (
    echo [ATTENTION] Pas d'acces ECR ou pas de repositories
)

echo.
echo [TEST 3] Verification permissions S3...
aws s3 ls 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Acces S3 autorise
) else (
    echo [ATTENTION] Pas d'acces S3
)

echo.
echo ========================================
echo CREDENTIALS VALIDES
echo ========================================
echo.
echo Copiez ces valeurs dans GitHub Secrets:
echo.
echo AWS_ACCESS_KEY_ID = %AWS_ACCESS_KEY%
echo AWS_SECRET_ACCESS_KEY = %AWS_SECRET_KEY%
echo AWS_DEFAULT_REGION = %AWS_REGION%
echo.
echo Pour ajouter dans GitHub:
echo 1. Aller sur: https://github.com/VOTRE_USER/VOTRE_REPO/settings/secrets/actions
echo 2. Cliquer "New repository secret"
echo 3. Ajouter chaque secret
echo.
pause
