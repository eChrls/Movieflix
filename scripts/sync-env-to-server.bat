@echo off
REM ===================================
REM SINCRONIZAR .ENV CON SERVIDOR ORANGE PI
REM MovieFlix - Fecha: 12 Sep 2025
REM ===================================

echo.
echo 🔄 SINCRONIZANDO ARCHIVO .ENV CON SERVIDOR ORANGE PI
echo ==================================================

REM Configuración del servidor
set SERVER_USER=casa74b
set SERVER_IP=192.168.1.50
set SERVER_PORT=2222
set SERVER_PATH=/var/www/MovieFlix

echo.
echo PASO 1: Verificando contenido del .env local
echo =============================================
if not exist ".env" (
    echo ❌ Error: No se encuentra el archivo .env en el directorio actual
    pause
    exit /b 1
)

echo Configuración actual:
echo ====================
findstr /R "DB_USER DB_PASSWORD TMDB_API_KEY OMDB_API_KEY" .env
echo.

echo PASO 2: Haciendo backup del .env del servidor
echo ==============================================
ssh -p %SERVER_PORT% %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && cp .env .env.backup.$(date +%%Y%%m%%d_%%H%%M%%S)"
if %errorlevel% neq 0 (
    echo ❌ Error creando backup del .env del servidor
    pause
    exit /b 1
)
echo ✅ Backup creado en el servidor

echo.
echo PASO 3: Copiando .env al servidor
echo ==================================
scp -P %SERVER_PORT% .env %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%/.env
if %errorlevel% neq 0 (
    echo ❌ Error copiando .env al servidor
    pause
    exit /b 1
)
echo ✅ Archivo .env copiado exitosamente

echo.
echo PASO 4: Verificando configuración en el servidor
echo ================================================
echo Configuración en el servidor:
echo =============================
ssh -p %SERVER_PORT% %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && grep -E '(DB_USER|DB_PASSWORD|TMDB_API_KEY|OMDB_API_KEY)' .env"
echo.

echo PASO 5: Reiniciando PM2 con nueva configuración
echo ===============================================
ssh -p %SERVER_PORT% %SERVER_USER%@%SERVER_IP% "cd %SERVER_PATH% && pm2 restart movieflix-backend --update-env"
if %errorlevel% neq 0 (
    echo ❌ Error reiniciando PM2
    pause
    exit /b 1
)
echo ✅ PM2 reiniciado con nueva configuración

echo.
echo PASO 6: Verificando logs del backend
echo ====================================
echo Últimos logs del backend:
echo ========================
ssh -p %SERVER_PORT% %SERVER_USER%@%SERVER_IP% "pm2 logs movieflix-backend --lines 10 --nostream"

echo.
echo ==================================================
echo ✅ SINCRONIZACIÓN COMPLETADA
echo ==================================================

echo.
echo PRÓXIMOS PASOS:
echo 1. Probar el endpoint: curl 'http://localhost:3001/api/search/suggestions?query=dune'
echo 2. Verificar la aplicación: https://home-movieflix.duckdns.org
echo 3. Introducir código: 5202
echo 4. Probar búsqueda predictiva
echo.
echo ✅ ¡El Error 500 debería estar resuelto! ✨

echo.
pause