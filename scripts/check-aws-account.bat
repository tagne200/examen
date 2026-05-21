@echo off
echo ========================================
echo Verification Compte AWS
echo ========================================
echo.

REM Vérifier si AWS CLI est installé
where aws >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] AWS CLI n'est pas installe
    echo.
    echo Telecharger depuis: https://aws.amazon.com/cli/
    echo.
    pause
    exit /b 1
)

echo [OK] AWS CLI installe
echo.

REM Vérifier si des credentials sont configurées
aws sts get-caller-identity >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Credentials AWS configurees
    echo.
    echo Informations du compte:
    aws sts get-caller-identity
    echo.
    echo ========================================
    echo COMPTE AWS ACCESSIBLE
    echo ========================================
    echo.
    echo Vous pouvez utiliser ce compte pour creer un utilisateur IAM.
    echo.
    echo Prochaines etapes:
    echo 1. Aller sur: https://console.aws.amazon.com/iam/
    echo 2. Creer un utilisateur: github-actions-digitrans
    echo 3. Attacher les permissions: ECR, S3, CloudFront
    echo 4. Creer les Access Keys
    echo 5. Tester avec: test-aws-credentials-interactive.bat
    echo.
) else (
    echo [ERREUR] Aucun compte AWS configure
    echo.
    echo SOLUTION 1: Configurer AWS CLI
    echo -----------------------------
    echo aws configure
    echo.
    echo Entrer:
    echo - AWS Access Key ID
    echo - AWS Secret Access Key
    echo - Default region: af-south-1
    echo - Default output format: json
    echo.
    echo SOLUTION 2: Utiliser AWS Console
    echo ---------------------------------
    echo 1. Aller sur: https://console.aws.amazon.com/
    echo 2. Se connecter avec votre compte root ou admin
    echo 3. Suivre le guide: docs\CREER-UTILISATEUR-IAM.md
    echo.
)

pause
