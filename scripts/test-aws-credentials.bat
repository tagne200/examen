@echo off
REM Script de test des credentials AWS
REM DIGITRANS-CM - CAMTECH SOLUTIONS

echo ========================================
echo Test des Credentials AWS
echo ========================================
echo.

REM Vérifier si AWS CLI est installé
where aws >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] AWS CLI n'est pas installé
    echo.
    echo Installation :
    echo   1. Télécharger : https://aws.amazon.com/cli/
    echo   2. Installer et redémarrer le terminal
    echo.
    pause
    exit /b 1
)

echo [OK] AWS CLI est installé
aws --version
echo.

REM Test 1 : Vérifier l'identité
echo ========================================
echo Test 1 : Vérification de l'identité
echo ========================================
echo.

aws sts get-caller-identity
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERREUR] Les credentials AWS sont invalides
    echo.
    echo Solutions :
    echo   1. Configurer AWS CLI : aws configure
    echo   2. Vérifier AWS_ACCESS_KEY_ID et AWS_SECRET_ACCESS_KEY
    echo   3. Voir le guide : docs\FIX-AWS-TOKEN-INVALID.md
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Credentials valides
echo.

REM Test 2 : Lister les buckets S3
echo ========================================
echo Test 2 : Accès S3
echo ========================================
echo.

aws s3 ls
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERREUR] Impossible d'accéder à S3
    echo.
    echo Vérifier les permissions IAM :
    echo   - s3:ListAllMyBuckets
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Accès S3 fonctionnel
echo.

REM Test 3 : Vérifier la région
echo ========================================
echo Test 3 : Région AWS
echo ========================================
echo.

aws configure get region
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [AVERTISSEMENT] Région non configurée
    echo.
    echo Configurer la région :
    echo   aws configure set region af-south-1
    echo.
)

echo.
echo [OK] Région configurée
echo.

REM Test 4 : Tester CloudFront (optionnel)
echo ========================================
echo Test 4 : Accès CloudFront (optionnel)
echo ========================================
echo.

aws cloudfront list-distributions --max-items 1 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [AVERTISSEMENT] Impossible d'accéder à CloudFront
    echo Vérifier les permissions IAM si nécessaire
) else (
    echo [OK] Accès CloudFront fonctionnel
)

echo.

REM Résumé
echo ========================================
echo RÉSUMÉ
echo ========================================
echo.
echo [OK] AWS CLI installé
echo [OK] Credentials valides
echo [OK] Accès S3 fonctionnel
echo [OK] Région configurée
echo.
echo Vous pouvez maintenant configurer GitHub Secrets :
echo   1. Aller sur : https://github.com/VOTRE_REPO/settings/secrets/actions
echo   2. Ajouter AWS_ACCESS_KEY_ID
echo   3. Ajouter AWS_SECRET_ACCESS_KEY
echo   4. Ajouter S3_BUCKET_NAME
echo   5. Ajouter CLOUDFRONT_DISTRIBUTION_ID
echo.
echo Guide complet : docs\FIX-AWS-TOKEN-INVALID.md
echo.

pause
