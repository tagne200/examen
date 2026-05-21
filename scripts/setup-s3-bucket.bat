@echo off
echo ========================================
echo CONFIGURATION BUCKET S3
echo ========================================
echo.

set BUCKET_NAME=digitrans-crm-frontend-prod
set REGION=af-south-1

echo Bucket: %BUCKET_NAME%
echo Region: %REGION%
echo.

REM Vérifier AWS CLI
where aws >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] AWS CLI non installe
    pause
    exit /b 1
)

echo [OK] AWS CLI installe
echo.

REM Vérifier connexion
aws sts get-caller-identity >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Pas de connexion AWS
    echo Configurez avec: aws configure
    pause
    exit /b 1
)

echo [OK] Connexion AWS active
echo.

echo Etape 1: Creation du bucket S3...
aws s3 mb s3://%BUCKET_NAME% --region %REGION% 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Bucket cree
) else (
    echo [INFO] Bucket existe deja ou erreur
)
echo.

echo Etape 2: Configuration pour hebergement web...
aws s3 website s3://%BUCKET_NAME% --index-document index.html --error-document index.html
if %ERRORLEVEL% EQU 0 (
    echo [OK] Configuration web activee
) else (
    echo [ERREUR] Echec configuration web
)
echo.

echo Etape 3: Desactivation du blocage public...
aws s3api put-public-access-block ^
    --bucket %BUCKET_NAME% ^
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
if %ERRORLEVEL% EQU 0 (
    echo [OK] Blocage public desactive
) else (
    echo [ERREUR] Echec desactivation blocage
)
echo.

echo Etape 4: Application de la politique publique...
aws s3api put-bucket-policy --bucket %BUCKET_NAME% --policy file://s3-bucket-policy.json
if %ERRORLEVEL% EQU 0 (
    echo [OK] Politique appliquee
) else (
    echo [ERREUR] Echec application politique
)
echo.

echo ========================================
echo CONFIGURATION TERMINEE
echo ========================================
echo.
echo URL du bucket:
echo http://%BUCKET_NAME%.s3-website.%REGION%.amazonaws.com
echo.
echo Ajoutez ce secret dans GitHub:
echo Name: S3_BUCKET_NAME
echo Value: %BUCKET_NAME%
echo.
pause
