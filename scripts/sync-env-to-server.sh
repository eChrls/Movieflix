#!/bin/bash
# ===================================
# SINCRONIZAR .ENV CON SERVIDOR ORANGE PI
# MovieFlix - Fecha: 12 Sep 2025
# ===================================

echo "🔄 SINCRONIZANDO ARCHIVO .ENV CON SERVIDOR ORANGE PI"
echo "=================================================="

# Configuración del servidor
SERVER_USER="casa74b"
SERVER_IP="192.168.1.50"
SERVER_PORT="2222"
SERVER_PATH="/var/www/MovieFlix"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_step() {
    echo -e "${BLUE}$1${NC}"
}

show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

show_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que existe el archivo .env local
if [ ! -f ".env" ]; then
    show_error "No se encuentra el archivo .env en el directorio actual"
    exit 1
fi

show_step "PASO 1: Verificando contenido del .env local"
echo "Configuración actual:"
echo "===================="
grep -E "(DB_USER|DB_PASSWORD|TMDB_API_KEY|OMDB_API_KEY)" .env
echo ""

show_step "PASO 2: Haciendo backup del .env del servidor"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && cp .env .env.backup.$(date +%Y%m%d_%H%M%S)" || {
    show_error "Error creando backup del .env del servidor"
    exit 1
}
show_success "Backup creado en el servidor"

show_step "PASO 3: Copiando .env al servidor"
scp -P $SERVER_PORT .env $SERVER_USER@$SERVER_IP:$SERVER_PATH/.env || {
    show_error "Error copiando .env al servidor"
    exit 1
}
show_success "Archivo .env copiado exitosamente"

show_step "PASO 4: Verificando configuración en el servidor"
echo "Configuración en el servidor:"
echo "============================="
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && grep -E '(DB_USER|DB_PASSWORD|TMDB_API_KEY|OMDB_API_KEY)' .env"
echo ""

show_step "PASO 5: Reiniciando PM2 con nueva configuración"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && pm2 restart movieflix-backend --update-env" || {
    show_error "Error reiniciando PM2"
    exit 1
}
show_success "PM2 reiniciado con nueva configuración"

show_step "PASO 6: Verificando logs del backend"
echo "Últimos logs del backend:"
echo "========================"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP "pm2 logs movieflix-backend --lines 10 --nostream"

echo ""
echo "=================================================="
show_success "SINCRONIZACIÓN COMPLETADA"
echo "=================================================="

echo ""
show_step "PRÓXIMOS PASOS:"
echo "1. Probar el endpoint: curl 'http://localhost:3001/api/search/suggestions?query=dune'"
echo "2. Verificar la aplicación: https://home-movieflix.duckdns.org"
echo "3. Introducir código: 5202"
echo "4. Probar búsqueda predictiva"

echo ""
show_success "¡El Error 500 debería estar resuelto! ✨"