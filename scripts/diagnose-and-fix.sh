#!/bin/bash

# ===================================
# SCRIPT DE DIAGNÓSTICO Y REPARACIÓN
# MovieFlix - Fecha: 12 Sep 2025
# ===================================

echo "🔍 DIAGNÓSTICO MOVIEFLIX - AUTOCOMPLETADO"
echo "========================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Verificar servicios
echo -e "\n${BLUE}1. VERIFICANDO SERVICIOS${NC}"
echo "----------------------------------------"

# MySQL
if systemctl is-active --quiet mysql; then
    echo -e "✅ MySQL: ${GREEN}Activo${NC}"
else
    echo -e "❌ MySQL: ${RED}Inactivo${NC}"
    echo "   Iniciando MySQL..."
    sudo systemctl start mysql
fi

# PM2
if pm2 list | grep -q "movieflix-backend"; then
    echo -e "✅ PM2 MovieFlix: ${GREEN}Ejecutándose${NC}"
    pm2 show movieflix-backend
else
    echo -e "❌ PM2 MovieFlix: ${RED}No ejecutándose${NC}"
fi

# 2. Verificar Base de Datos
echo -e "\n${BLUE}2. VERIFICANDO BASE DE DATOS${NC}"
echo "----------------------------------------"

# Verificar conexión y permisos
mysql -u root -p -e "
SELECT 'Verificando usuarios...' as Status;
SELECT user, host FROM mysql.user WHERE user = 'movieflix_user';

SELECT 'Verificando permisos...' as Status;
SHOW GRANTS FOR 'movieflix_user'@'%';

USE movieflix_db;
SELECT 'Contando contenido...' as Status;
SELECT COUNT(*) as total_content FROM content;
SELECT COUNT(*) as total_profiles FROM profiles;

SELECT 'Verificando estructura...' as Status;
SHOW TABLES;
"

# 3. Aplicar fix de permisos si es necesario
echo -e "\n${BLUE}3. APLICANDO FIX DE PERMISOS${NC}"
echo "----------------------------------------"

read -p "¿Aplicar fix de permisos de BD? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Aplicando fix de permisos..."
    mysql -u root -p < /home/movieflix/MovieFlix/scripts/fix-db-permissions.sql
    echo -e "${GREEN}✅ Permisos aplicados${NC}"
fi

# 4. Verificar variables de entorno
echo -e "\n${BLUE}4. VERIFICANDO VARIABLES DE ENTORNO${NC}"
echo "----------------------------------------"

cd /home/movieflix/MovieFlix/backend

if [ -f .env ]; then
    echo -e "✅ Archivo .env encontrado"
    echo "Variables críticas:"
    grep -E "^(DB_HOST|DB_USER|DB_NAME|PORT)=" .env | sed 's/^/   /'
else
    echo -e "${RED}❌ Archivo .env no encontrado${NC}"
fi

# 5. Reiniciar servicios
echo -e "\n${BLUE}5. REINICIANDO SERVICIOS${NC}"
echo "----------------------------------------"

read -p "¿Reiniciar PM2 con variables actualizadas? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Reiniciando PM2..."
    pm2 restart movieflix-backend --update-env
    echo -e "${GREEN}✅ PM2 reiniciado${NC}"
fi

# 6. Test de endpoints
echo -e "\n${BLUE}6. TESTING ENDPOINTS CRÍTICOS${NC}"
echo "----------------------------------------"

echo "Testing endpoint de sugerencias..."
curl -s "http://localhost:3001/api/search/suggestions?query=dune" | head -c 200
echo -e "\n"

echo "Testing endpoint de contenido..."
curl -s "http://localhost:3001/api/content/1" | head -c 200
echo -e "\n"

# 7. Logs recientes
echo -e "\n${BLUE}7. LOGS RECIENTES${NC}"
echo "----------------------------------------"
echo "Últimas 10 líneas de logs PM2:"
pm2 logs movieflix-backend --lines 10 --nostream

echo -e "\n${GREEN}🎉 DIAGNÓSTICO COMPLETADO${NC}"
echo "========================================="
echo "Si los endpoints funcionan localmente pero no desde el frontend:"
echo "1. Verificar que nginx está proxy-pasando correctamente"
echo "2. Verificar que el código de acceso 5202 se está validando"
echo "3. Verificar que el frontend está haciendo las llamadas correctas"
