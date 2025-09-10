@echo off
echo 🔧 MovieFlix - Corrección URLs Pósters TMDb
echo ==========================================
echo.

REM Verificar que estamos en el directorio correcto
if not exist "scripts\fix-poster-urls.js" (
    echo ❌ Error: Ejecuta este script desde el directorio backend de MovieFlix
    echo Ubicación correcta: MovieFlix\backend\
    pause
    exit /b 1
)

echo 🔍 Paso 1: Verificando URLs actuales...
echo.

REM Ejecutar script de corrección
node scripts\fix-poster-urls.js

echo.
echo ✅ Corrección completada!
echo.
echo 🎯 Paso 2: Verificación manual:
echo 1. Si tienes el servidor local ejecutándose, reinícialo
echo 2. Abre la aplicación en el navegador
echo 3. Presiona Ctrl+F5 para limpiar caché del navegador
echo 4. Verifica que las portadas ahora cargan correctamente
echo.
echo 🎉 ¡Proceso completado!
echo.
pause
