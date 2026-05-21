@echo off
echo ========================================
echo CREATION CLOUDFRONT DISTRIBUTION
echo ========================================
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

set /p BUCKET_NAME="Entrez le nom du bucket S3 (ex: digitrans-crm-frontend-prod): "

if "%BUCKET_NAME%"=="" (
    echo [ERREUR] Nom de bucket requis
    pause
    exit /b 1
)

echo.
echo Creation de la distribution CloudFront...
echo.

REM Créer le fichier de configuration CloudFront
echo { > cloudfront-config.json
echo   "CallerReference": "%BUCKET_NAME%-%RANDOM%", >> cloudfront-config.json
echo   "Comment": "Distribution CloudFront pour DIGITRANS-CM CRM", >> cloudfront-config.json
echo   "Enabled": true, >> cloudfront-config.json
echo   "Origins": { >> cloudfront-config.json
echo     "Quantity": 1, >> cloudfront-config.json
echo     "Items": [ >> cloudfront-config.json
echo       { >> cloudfront-config.json
echo         "Id": "S3-%BUCKET_NAME%", >> cloudfront-config.json
echo         "DomainName": "%BUCKET_NAME%.s3-website.af-south-1.amazonaws.com", >> cloudfront-config.json
echo         "CustomOriginConfig": { >> cloudfront-config.json
echo           "HTTPPort": 80, >> cloudfront-config.json
echo           "HTTPSPort": 443, >> cloudfront-config.json
echo           "OriginProtocolPolicy": "http-only" >> cloudfront-config.json
echo         } >> cloudfront-config.json
echo       } >> cloudfront-config.json
echo     ] >> cloudfront-config.json
echo   }, >> cloudfront-config.json
echo   "DefaultCacheBehavior": { >> cloudfront-config.json
echo     "TargetOriginId": "S3-%BUCKET_NAME%", >> cloudfront-config.json
echo     "ViewerProtocolPolicy": "redirect-to-https", >> cloudfront-config.json
echo     "AllowedMethods": { >> cloudfront-config.json
echo       "Quantity": 2, >> cloudfront-config.json
echo       "Items": ["GET", "HEAD"] >> cloudfront-config.json
echo     }, >> cloudfront-config.json
echo     "Compress": true, >> cloudfront-config.json
echo     "ForwardedValues": { >> cloudfront-config.json
echo       "QueryString": false, >> cloudfront-config.json
echo       "Cookies": { >> cloudfront-config.json
echo         "Forward": "none" >> cloudfront-config.json
echo       } >> cloudfront-config.json
echo     }, >> cloudfront-config.json
echo     "MinTTL": 0 >> cloudfront-config.json
echo   } >> cloudfront-config.json
echo } >> cloudfront-config.json

REM Créer la distribution
aws cloudfront create-distribution --distribution-config file://cloudfront-config.json > cloudfront-output.json 2>nul

if %ERRORLEVEL% EQU 0 (
    echo [OK] Distribution CloudFront creee
    echo.
    
    REM Extraire l'ID
    for /f "tokens=*" %%i in ('aws cloudfront list-distributions --query "DistributionList.Items[0].Id" --output text') do set DISTRIBUTION_ID=%%i
    
    echo ========================================
    echo CLOUDFRONT DISTRIBUTION ID
    echo ========================================
    echo.
    echo %DISTRIBUTION_ID%
    echo.
    echo Copiez cet ID dans GitHub Secrets:
    echo Name: CLOUDFRONT_DISTRIBUTION_ID
    echo Value: %DISTRIBUTION_ID%
    echo.
    
    REM Obtenir le domain name
    for /f "tokens=*" %%i in ('aws cloudfront list-distributions --query "DistributionList.Items[0].DomainName" --output text') do set DOMAIN_NAME=%%i
    
    echo URL CloudFront:
    echo https://%DOMAIN_NAME%
    echo.
    echo ATTENTION: La distribution prend 15-20 minutes pour etre deployee
    echo.
) else (
    echo [ERREUR] Echec de creation
    echo Verifiez les permissions CloudFront
)

REM Nettoyer
del cloudfront-config.json 2>nul
del cloudfront-output.json 2>nul

pause
