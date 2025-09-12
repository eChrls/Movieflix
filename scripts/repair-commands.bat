@echo off
REM ===================================
REM COMANDOS PARA ARREGLAR MOVIEFLIX
REM Windows Batch Script
REM Fecha: 12 Sep 2025
REM ===================================

echo.
echo 🔧 MOVIEFLIX - COMANDOS DE REPARACION
echo =====================================

echo.
echo PASO 1: Subir archivos al servidor Orange Pi
echo ---------------------------------------------
echo scp scripts/fix-db-permissions.sql usuario@192.168.1.50:/home/movieflix/MovieFlix/scripts/
echo scp scripts/diagnose-and-fix.sh usuario@192.168.1.50:/home/movieflix/MovieFlix/scripts/
echo scp ecosystem.config.js usuario@192.168.1.50:/home/movieflix/MovieFlix/
echo scp backend/server.js usuario@192.168.1.50:/home/movieflix/MovieFlix/backend/

echo.
echo PASO 2: Conectar al servidor y ejecutar reparaciones
echo ---------------------------------------------------
echo ssh usuario@192.168.1.50

echo.
echo PASO 3: En el servidor, ejecutar los siguientes comandos:
echo --------------------------------------------------------
echo cd /home/movieflix/MovieFlix

echo.
echo # 3.1 Arreglar permisos de base de datos
echo mysql -u root -p ^< scripts/fix-db-permissions.sql

echo.
echo # 3.2 Hacer ejecutable el script de diagnóstico
echo chmod +x scripts/diagnose-and-fix.sh

echo.
echo # 3.3 Ejecutar diagnóstico completo
echo ./scripts/diagnose-and-fix.sh

echo.
echo # 3.4 Reiniciar PM2 con nueva configuración
echo pm2 delete movieflix 2^>nul
echo pm2 start ecosystem.config.js --env production
echo pm2 save

echo.
echo PASO 4: Verificar que todo funciona
echo ----------------------------------
echo # 4.1 Verificar logs
echo pm2 logs movieflix-backend --lines 20

echo.
echo # 4.2 Test endpoint de sugerencias
echo curl "http://localhost:3001/api/search/suggestions?query=dune"

echo.
echo # 4.3 Test endpoint de contenido
echo curl "http://localhost:3001/api/content/1"

echo.
echo PASO 5: Si todo funciona localmente, verificar desde external
echo ----------------------------------------------------------
echo # Desde tu PC, probar:
echo curl "http://192.168.1.50:3001/api/search/suggestions?query=dune"

echo.
echo 🎯 COMANDOS DE EMERGENCIA (si algo falla)
echo ==========================================
echo # Rollback a usuario root temporalmente:
echo # En server.js cambiar: user: "root", password: "$@msunG--2025"
echo # pm2 restart movieflix-backend

echo.
echo # Ver usuarios de MySQL:
echo # mysql -u root -p -e "SELECT user, host FROM mysql.user WHERE user IN ('movieflix_user', 'root');"

echo.
echo # Verificar permisos:
echo # mysql -u root -p -e "SHOW GRANTS FOR 'movieflix_user'@'192.168.1.50';"

echo.
echo ✅ TODOS LOS COMANDOS LISTADOS
echo ==============================
echo Copia y pega estos comandos en orden en tu terminal SSH

pause
