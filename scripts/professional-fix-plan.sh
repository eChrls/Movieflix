#!/bin/bash
# ===================================
# PLAN PROFESIONAL DE REPARACIÓN - MOVIEFLIX
# Fecha: 12 Sep 2025
# Servidor: Orange Pi 5 Plus (192.168.1.50)
# ===================================

echo "🚀 INICIANDO PLAN DE REPARACIÓN PROFESIONAL MOVIEFLIX"
echo "=================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar pasos
show_step() {
    echo -e "${BLUE}$1${NC}"
}

# Función para mostrar éxito
show_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar error
show_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para mostrar advertencia
show_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -d "/var/www/MovieFlix" ]; then
    show_error "No se encuentra el directorio /var/www/MovieFlix"
    exit 1
fi

cd /var/www/MovieFlix

show_step "PASO 1: EJECUTAR FIX DE PERMISOS MYSQL ⚙️"
echo "Aplicando permisos de MySQL para movieflix_user..."

if mysql -u root -p < scripts/fix-db-permissions.sql; then
    show_success "Permisos MySQL aplicados correctamente"
else
    show_error "Error aplicando permisos MySQL"
    exit 1
fi

show_step "PASO 2: VERIFICAR ARCHIVO .ENV 🔍"
echo "Verificando configuración de variables de entorno..."

if [ -f ".env" ]; then
    show_success "Archivo .env encontrado"
    
    # Verificar APIs configuradas
    if grep -q "TMDB_API_KEY=a2e351c494039319d6d537923a7d972a" .env; then
        show_success "TMDB_API_KEY configurada correctamente"
    else
        show_warning "TMDB_API_KEY no está configurada. Actualizando..."
        sed -i 's/TMDB_API_KEY=.*/TMDB_API_KEY=a2e351c494039319d6d537923a7d972a/' .env
    fi
    
    if grep -q "OMDB_API_KEY=ee43f6ac" .env; then
        show_success "OMDB_API_KEY configurada correctamente"
    else
        show_warning "OMDB_API_KEY no está configurada. Actualizando..."
        sed -i 's/OMDB_API_KEY=.*/OMDB_API_KEY=ee43f6ac/' .env
    fi
    
    if grep -q "DB_USER=movieflix_user" .env; then
        show_success "DB_USER configurado correctamente"
    else
        show_warning "DB_USER incorrecto. Actualizando..."
        sed -i 's/DB_USER=.*/DB_USER=movieflix_user/' .env
    fi
else
    show_error "Archivo .env no encontrado"
    exit 1
fi

show_step "PASO 3: REINICIAR PM2 CON VARIABLES ACTUALIZADAS 🔄"
echo "Reiniciando backend con nuevas variables..."

pm2 restart movieflix-backend --update-env
sleep 3

show_success "Backend reiniciado"
echo "Últimos logs:"
pm2 logs movieflix-backend --lines 10 --nostream

show_step "PASO 4: VERIFICAR CONEXIÓN DE BASE DE DATOS 🔍"
echo "Verificando estado de la base de datos..."

if mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db < scripts/verify-database-status.sql; then
    show_success "Conexión a BD verificada exitosamente"
else
    show_error "Error conectando a la base de datos"
    exit 1
fi

show_step "PASO 5: TESTING DE ENDPOINTS CRÍTICOS 🧪"
echo "Probando endpoints de la API..."

# Test health check
echo "Testing health check..."
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/health_response.json "http://localhost:3001/api/health")
if [ "$HEALTH_RESPONSE" = "200" ]; then
    show_success "Health check: HTTP 200"
    cat /tmp/health_response.json | jq '.' 2>/dev/null || cat /tmp/health_response.json
else
    show_error "Health check falló: HTTP $HEALTH_RESPONSE"
fi

echo ""

# Test sugerencias (endpoint problemático)
echo "Testing búsqueda de sugerencias..."
SUGGESTIONS_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/suggestions_response.json "http://localhost:3001/api/search/suggestions?query=dune")
if [ "$SUGGESTIONS_RESPONSE" = "200" ]; then
    show_success "Sugerencias: HTTP 200"
    cat /tmp/suggestions_response.json | jq '.results | length' 2>/dev/null || echo "Respuesta recibida"
else
    show_error "Sugerencias falló: HTTP $SUGGESTIONS_RESPONSE"
    cat /tmp/suggestions_response.json 2>/dev/null || echo "Sin respuesta"
fi

echo ""

# Test contenido de perfil
echo "Testing contenido de perfil..."
CONTENT_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/content_response.json "http://localhost:3001/api/content/1")
if [ "$CONTENT_RESPONSE" = "200" ]; then
    show_success "Contenido: HTTP 200"
else
    show_error "Contenido falló: HTTP $CONTENT_RESPONSE"
fi

show_step "PASO 6: VERIFICAR SERVICIOS DEL SISTEMA 🛠️"
echo "Verificando servicios críticos..."

# Verificar Nginx
if systemctl is-active --quiet nginx; then
    show_success "Nginx está activo"
else
    show_warning "Nginx no está activo, iniciando..."
    sudo systemctl start nginx
fi

# Verificar MySQL
if systemctl is-active --quiet mysql; then
    show_success "MySQL está activo"
else
    show_warning "MySQL no está activo, iniciando..."
    sudo systemctl start mysql
fi

# Verificar PM2
if pm2 list | grep -q "movieflix-backend.*online"; then
    show_success "PM2 movieflix-backend está online"
else
    show_error "PM2 movieflix-backend no está online"
fi

echo ""
echo "=================================================="
echo "🎉 PLAN DE REPARACIÓN COMPLETADO"
echo "=================================================="

show_step "PRÓXIMOS PASOS:"
echo "1. Probar la aplicación en: https://home-movieflix.duckdns.org"
echo "2. Introducir código: 5202"
echo "3. Verificar que se cargan películas"
echo "4. Probar búsqueda predictiva escribiendo 'dune'"

show_step "SI PERSISTEN PROBLEMAS:"
echo "- Revisar logs: pm2 logs movieflix-backend"
echo "- Verificar firewall: sudo ufw status"
echo "- Verificar bind-address MySQL: sudo cat /etc/mysql/mysql.conf.d/mysqld.cnf | grep bind-address"

# Limpiar archivos temporales
rm -f /tmp/health_response.json /tmp/suggestions_response.json /tmp/content_response.json

echo ""
show_success "Script finalizado exitosamente ✨"