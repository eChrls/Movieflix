@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 🔧 MovieFlix - Actualizador de Contenido Seguro
echo ==============================================
echo.

REM Verificar que estamos en el directorio correcto
if not exist "package.json" (
    echo ❌ Error: Ejecuta este script desde el directorio backend de MovieFlix
    pause
    exit /b 1
)

if not exist "scripts" (
    echo ❌ Error: Directorio scripts no encontrado
    pause
    exit /b 1
)

REM Verificar que el archivo .env existe
if not exist ".env" (
    echo ❌ Error: Archivo .env no encontrado
    echo    Asegúrate de tener configuradas las API keys de TMDb y OMDb
    pause
    exit /b 1
)

REM Crear directorio de backup si no existe
if not exist "backup" mkdir backup

REM Crear nombre de backup con fecha
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

set "BACKUP_FILE=backup\movieflix_before_content_update_%datestamp%.sql"

echo 📦 Creando backup de seguridad...

REM Leer variables del archivo .env
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="DB_HOST" set "DB_HOST=%%b"
    if "%%a"=="DB_USER" set "DB_USER=%%b"
    if "%%a"=="DB_PASSWORD" set "DB_PASSWORD=%%b"
    if "%%a"=="DB_NAME" set "DB_NAME=%%b"
)

REM Crear backup usando mysqldump (si está disponible)
mysqldump -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% content > "%BACKUP_FILE%" 2>nul

if %errorlevel% equ 0 (
    for %%A in ("%BACKUP_FILE%") do set "BACKUP_SIZE=%%~zA"
    echo ✅ Backup creado: %BACKUP_FILE% (!BACKUP_SIZE! bytes)
) else (
    echo ⚠️  Warning: No se pudo crear backup automático
    echo    Continúa bajo tu responsabilidad
    set /p "continue=¿Deseas continuar? (y/N): "
    if /i not "!continue!"=="y" (
        echo ❌ Operación cancelada
        pause
        exit /b 1
    )
)

echo.

REM Ejecutar análisis previo
echo 🔍 Analizando contenido incompleto...
node scripts/analyze-incomplete-content.js

echo.
set /p "continue=¿Deseas continuar con la actualización? (y/N): "
if /i not "%continue%"=="y" (
    echo ❌ Actualización cancelada
    pause
    exit /b 0
)

echo.
echo 🚀 Iniciando actualización de contenido...
echo    Esto puede tomar varios minutos dependiendo de la cantidad de contenido
echo.

REM Ejecutar actualización
node scripts/update-incomplete-content.js

if %errorlevel% equ 0 (
    echo.
    echo 🎉 ¡Actualización completada exitosamente!
    echo.
    echo 📋 Próximos pasos:
    echo    1. Verifica la aplicación web en el navegador
    echo    2. Comprueba que los pósters y ratings se muestran correctamente
    echo    3. Si hay problemas, restaura desde: %BACKUP_FILE%
    echo.
    echo 🔄 Para restaurar el backup en caso de problemas:
    echo    mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% ^< %BACKUP_FILE%
) else (
    echo.
    echo ❌ Error durante la actualización
    echo 🔄 Para restaurar el backup:
    echo    mysql -h%DB_HOST% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% ^< %BACKUP_FILE%
)

echo.
pause
