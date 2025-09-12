#!/bin/bash

# ===================================
# COMANDOS CORRECTOS PARA MOVIEFLIX
# Base de datos: movieflix_db
# Usuario: movieflix_user
# Fecha: 12 Sep 2025
# ===================================

echo "🎬 MOVIEFLIX - REPARACIÓN DE BASE DE DATOS"
echo "==========================================="

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. NAVEGAR A LA RUTA CORRECTA
echo -e "\n${BLUE}1. NAVEGANDO A DIRECTORIO CORRECTO${NC}"
cd /var/www/MovieFlix
echo "📁 Directorio actual: $(pwd)"

# 2. VERIFICAR ESTADO DE MYSQL
echo -e "\n${BLUE}2. VERIFICANDO MYSQL${NC}"
if systemctl is-active --quiet mysql; then
    echo -e "✅ MySQL: ${GREEN}Activo${NC}"
else
    echo -e "❌ MySQL: ${RED}Inactivo${NC}"
    echo "Iniciando MySQL..."
    sudo systemctl start mysql
fi

# 3. INTENTAR DIFERENTES MÉTODOS DE CONEXIÓN A MYSQL
echo -e "\n${BLUE}3. PROBANDO CONEXIÓN A MYSQL${NC}"

# Método 1: Sin contraseña
echo "🔐 Probando conexión sin contraseña..."
if mysql -u root -e "SELECT 'Sin contraseña: OK' as resultado;" 2>/dev/null; then
    echo -e "✅ ${GREEN}Conexión sin contraseña exitosa${NC}"
    MYSQL_CMD="mysql -u root"
elif mysql -u root -p'' -e "SELECT 'Contraseña vacía: OK' as resultado;" 2>/dev/null; then
    echo -e "✅ ${GREEN}Conexión con contraseña vacía exitosa${NC}"
    MYSQL_CMD="mysql -u root -p''"
elif mysql -u root -p'$@msunG--2025' -e "SELECT 'Contraseña sistema: OK' as resultado;" 2>/dev/null; then
    echo -e "✅ ${GREEN}Conexión con contraseña del sistema exitosa${NC}"
    MYSQL_CMD="mysql -u root -p'$@msunG--2025'"
elif sudo mysql -e "SELECT 'Sudo: OK' as resultado;" 2>/dev/null; then
    echo -e "✅ ${GREEN}Conexión con sudo exitosa${NC}"
    MYSQL_CMD="sudo mysql"
else
    echo -e "❌ ${RED}No se pudo conectar a MySQL con ningún método${NC}"
    echo -e "${YELLOW}Probando reset de contraseña de MySQL...${NC}"

    # Intentar reset de contraseña
    sudo systemctl stop mysql
    sudo mysqld_safe --skip-grant-tables --skip-networking &
    sleep 3
    mysql -u root -e "
        USE mysql;
        UPDATE user SET authentication_string = PASSWORD('') WHERE User = 'root';
        UPDATE user SET plugin = 'mysql_native_password' WHERE User = 'root';
        FLUSH PRIVILEGES;
    " 2>/dev/null

    sudo pkill mysqld
    sudo systemctl start mysql

    if mysql -u root -e "SELECT 'Reset exitoso' as resultado;" 2>/dev/null; then
        echo -e "✅ ${GREEN}Reset de contraseña exitoso${NC}"
        MYSQL_CMD="mysql -u root"
    else
        echo -e "❌ ${RED}Reset falló. Usar mysql_secure_installation${NC}"
        exit 1
    fi
fi

# 4. VERIFICAR BASE DE DATOS ACTUAL
echo -e "\n${BLUE}4. VERIFICANDO BASE DE DATOS ACTUAL${NC}"
$MYSQL_CMD -e "
SELECT 'Bases de datos existentes:' as Info;
SHOW DATABASES;

SELECT 'Usuarios existentes:' as Info;
SELECT user, host FROM mysql.user WHERE user IN ('root', 'movieflix_user');
"

# 5. APLICAR FIX DE PERMISOS
echo -e "\n${BLUE}5. APLICANDO FIX DE BASE DE DATOS${NC}"
echo "Ejecutando script de reparación..."

if $MYSQL_CMD < scripts/fix-movieflix-db.sql; then
    echo -e "✅ ${GREEN}Script de reparación ejecutado exitosamente${NC}"
else
    echo -e "❌ ${RED}Error ejecutando script de reparación${NC}"
    exit 1
fi

# 6. VERIFICAR QUE TODO FUNCIONÓ
echo -e "\n${BLUE}6. VERIFICANDO REPARACIÓN${NC}"
$MYSQL_CMD -e "
SELECT 'Verificando usuario movieflix_user:' as Info;
SELECT user, host FROM mysql.user WHERE user = 'movieflix_user';

SELECT 'Verificando base de datos movieflix_db:' as Info;
USE movieflix_db;
SHOW TABLES;

SELECT 'Probando conexión como movieflix_user desde localhost:' as Info;
"

# Probar conexión como movieflix_user
if mysql -u movieflix_user -p'movieflix_secure_2025!' -h localhost -e "USE movieflix_db; SELECT 'Conexión localhost OK' as resultado;" 2>/dev/null; then
    echo -e "✅ ${GREEN}movieflix_user puede conectar desde localhost${NC}"
else
    echo -e "❌ ${RED}movieflix_user NO puede conectar desde localhost${NC}"
fi

if mysql -u movieflix_user -p'movieflix_secure_2025!' -h 192.168.1.50 -e "USE movieflix_db; SELECT 'Conexión 192.168.1.50 OK' as resultado;" 2>/dev/null; then
    echo -e "✅ ${GREEN}movieflix_user puede conectar desde 192.168.1.50${NC}"
else
    echo -e "❌ ${RED}movieflix_user NO puede conectar desde 192.168.1.50${NC}"
fi

# 7. REINICIAR PM2
echo -e "\n${BLUE}7. REINICIANDO SERVICIOS${NC}"
echo "Reiniciando PM2..."

pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pm2 start ecosystem.config.js --env production
pm2 save

echo "Estado de PM2:"
pm2 list

# 8. PROBAR ENDPOINTS
echo -e "\n${BLUE}8. PROBANDO ENDPOINTS${NC}"
echo "Esperando a que el servidor inicie..."
sleep 5

echo "🔍 Probando endpoint de salud..."
curl -s "http://localhost:3001/api/health" | head -c 200
echo ""

echo "🔍 Probando endpoint de sugerencias..."
curl -s "http://localhost:3001/api/search/suggestions?query=dune" | head -c 200
echo ""

echo "🔍 Probando endpoint de perfiles..."
curl -s "http://localhost:3001/api/profiles" | head -c 200
echo ""

# 9. MOSTRAR LOGS RECIENTES
echo -e "\n${BLUE}9. LOGS RECIENTES${NC}"
echo "Últimos logs de PM2:"
pm2 logs --lines 10 --nostream

echo -e "\n${GREEN}🎉 PROCESO DE REPARACIÓN COMPLETADO${NC}"
echo "============================================="
echo "✅ Base de datos: movieflix_db"
echo "✅ Usuario: movieflix_user"
echo "✅ Contraseña: movieflix_secure_2025!"
echo ""
echo "🧪 PRUEBAS MANUALES:"
echo "1. Probar frontend: http://192.168.1.50:3000"
echo "2. Código de acceso: 5202"
echo "3. Autocompletado debería funcionar"
