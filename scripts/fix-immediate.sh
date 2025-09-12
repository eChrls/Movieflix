#!/bin/bash

# ===================================
# COMANDOS CORREGIDOS PARA MOVIEFLIX
# Orange Pi Server - 12 Sep 2025
# Ruta correcta: /var/www/MovieFlix
# ===================================

echo "🔧 SOLUCIONANDO PROBLEMAS DE MOVIEFLIX"
echo "======================================"

# 1. NAVEGAMOS A LA RUTA CORRECTA
echo "📁 Navegando a la ruta correcta..."
cd /var/www/MovieFlix
pwd

# 2. DAR PERMISOS DE EJECUCIÓN AL SCRIPT
echo "🔑 Dando permisos de ejecución..."
chmod +x scripts/diagnose-and-fix.sh
ls -la scripts/

# 3. INTENTAR CONECTAR A MYSQL CON DIFERENTES USUARIOS
echo "🔐 Probando conexión MySQL..."

# Verificar qué usuario root existe y su contraseña
echo "Verificando usuarios MySQL disponibles..."

# Opción 1: Sin contraseña
echo "Intentando sin contraseña..."
mysql -u root -e "SELECT 'Conexión exitosa sin contraseña' as resultado;" 2>/dev/null || echo "❌ Sin contraseña falló"

# Opción 2: Con contraseña vacía
echo "Intentando con contraseña vacía..."
mysql -u root -p'' -e "SELECT 'Conexión exitosa con contraseña vacía' as resultado;" 2>/dev/null || echo "❌ Contraseña vacía falló"

# Opción 3: Con contraseña común del Orange Pi
echo "Intentando con contraseña del sistema..."
mysql -u root -p'$@msunG--2025' -e "SELECT 'Conexión exitosa con contraseña sistema' as resultado;" 2>/dev/null || echo "❌ Contraseña sistema falló"

# 4. VERIFICAR ESTADO DE MYSQL
echo "📊 Estado de MySQL..."
sudo systemctl status mysql --no-pager -l

# 5. VERIFICAR USUARIOS EXISTENTES EN MYSQL (si logramos conectar)
echo "👥 Intentando ver usuarios existentes..."

# Usar sudo para acceso a MySQL si es necesario
sudo mysql -e "
SELECT 'Usuarios en MySQL:' as Info;
SELECT user, host, authentication_string FROM mysql.user WHERE user IN ('root', 'movieflix_user');
SELECT '---' as separator;
SELECT 'Databases disponibles:' as Info;
SHOW DATABASES;
" 2>/dev/null || echo "❌ No se pudo acceder a MySQL como sudo"

# 6. REVISAR LOGS DE MYSQL PARA VER ERRORES
echo "📋 Últimos logs de MySQL..."
sudo tail -20 /var/log/mysql/error.log 2>/dev/null || echo "❌ No se pudieron leer logs de MySQL"

# 7. VERIFICAR PROCESO PM2 ACTUAL
echo "🚀 Estado actual de PM2..."
pm2 list
pm2 logs --lines 10

echo ""
echo "🎯 PRÓXIMOS PASOS RECOMENDADOS:"
echo "================================"
echo "1. Si MySQL no acepta ninguna contraseña, reiniciar en modo safe:"
echo "   sudo systemctl stop mysql"
echo "   sudo mysqld_safe --skip-grant-tables &"
echo ""
echo "2. O resetear contraseña de root MySQL:"
echo "   sudo mysql_secure_installation"
echo ""
echo "3. Una vez que MySQL funcione, ejecutar:"
echo "   mysql -u root -p < scripts/fix-db-permissions.sql"
echo ""
echo "4. Y finalmente reiniciar el backend:"
echo "   pm2 restart movieflix-backend"
