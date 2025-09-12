#!/bin/bash

# 🎬 MovieFlix Demo Deployment Script
# Despliega la versión demo para portfolio manteniendo la versión de producción

echo "🎭 =============================================="
echo "🎬 MovieFlix Demo Deployment Script"
echo "🎯 Configurando modo demostración para portfolio"
echo "=============================================="

# Variables de configuración
DEMO_PORT=3002
DEMO_PM2_NAME="movieflix-demo"
DEMO_NGINX_CONFIG="movieflix-demo"
DEMO_DOMAIN="home-movieflix.duckdns.org"
PROJECT_PATH="/var/www/MovieFlix"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging con colores
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar que estamos en el servidor correcto
if [[ ! -d "$PROJECT_PATH" ]]; then
    error "No se encontró el directorio del proyecto en $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

log "📍 Ubicación actual: $(pwd)"

# 1. Verificar dependencias
log "🔍 Verificando dependencias..."

if ! command -v pm2 &> /dev/null; then
    error "PM2 no está instalado"
    exit 1
fi

if ! command -v nginx &> /dev/null; then
    error "Nginx no está instalado"
    exit 1
fi

if ! command -v node &> /dev/null; then
    error "Node.js no está instalado"
    exit 1
fi

log "✅ Todas las dependencias están disponibles"

# 2. Instalar rate-limit si no existe
log "📦 Verificando/Instalando express-rate-limit..."
cd backend
if ! npm list express-rate-limit &> /dev/null; then
    npm install express-rate-limit
    log "✅ express-rate-limit instalado"
else
    log "✅ express-rate-limit ya está disponible"
fi
cd ..

# 3. Crear archivo .env específico para demo
log "⚙️ Configurando variables de entorno para demo..."

cat > .env.demo << EOF
# 🎭 MovieFlix Demo Configuration
NODE_ENV=demo
PORT=$DEMO_PORT
DEMO_MODE=true
DEMO_CODE=5202
DEMO_PASSWORD=demo2024

# API Keys (mantener las reales para funcionalidad completa)
OMDB_API_KEY=$OMDB_API_KEY
TMDB_API_KEY=$TMDB_API_KEY

# Base de datos (NO USAR EN DEMO)
# Las siguientes variables están comentadas intencionalmente
# DB_HOST=localhost
# DB_USER=movieflix_user
# DB_PASSWORD=movieflix_secure_2025!
# DB_NAME=movieflix_db

# Demo headers
DEMO_BANNER=true
DEMO_GITHUB_URL=https://github.com/eChrls/Movieflix
EOF

log "✅ Archivo .env.demo creado"

# 4. Construir frontend con variables demo
log "🏗️ Construyendo frontend en modo demo..."

cd frontend

# Crear build específico para demo
REACT_APP_DEMO_MODE=true npm run build

if [[ $? -eq 0 ]]; then
    log "✅ Build de frontend demo completado"
else
    error "❌ Error en el build del frontend demo"
    exit 1
fi

cd ..

# 5. Crear configuración PM2 específica para demo
log "⚙️ Configurando PM2 para modo demo..."

cat > ecosystem.demo.config.js << EOF
module.exports = {
  apps: [{
    name: '$DEMO_PM2_NAME',
    script: 'backend/server.js',
    env: {
      NODE_ENV: 'demo',
      PORT: $DEMO_PORT,
      DEMO_MODE: 'true',
      DEMO_CODE: '5202',
      DEMO_PASSWORD: 'demo2024'
    },
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '500M',
    error_file: './logs/demo-error.log',
    out_file: './logs/demo-out.log',
    log_file: './logs/demo-combined.log',
    time: true,
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
EOF

log "✅ Configuración PM2 demo creada"

# 6. Detener instancia demo anterior si existe
log "🔄 Gestionando instancia PM2 anterior..."

if pm2 list | grep -q "$DEMO_PM2_NAME"; then
    warning "Deteniendo instancia demo anterior..."
    pm2 stop "$DEMO_PM2_NAME"
    pm2 delete "$DEMO_PM2_NAME"
fi

# 7. Iniciar nueva instancia demo
log "🚀 Iniciando MovieFlix en modo demo..."

pm2 start ecosystem.demo.config.js

if [[ $? -eq 0 ]]; then
    log "✅ MovieFlix demo iniciado correctamente en puerto $DEMO_PORT"
else
    error "❌ Error al iniciar MovieFlix demo"
    exit 1
fi

# 8. Configurar Nginx para demo
log "🌐 Configurando Nginx para ruta demo..."

cat > /etc/nginx/sites-available/$DEMO_NGINX_CONFIG << EOF
# MovieFlix Demo Configuration
location /movieflix-demo {
    proxy_pass http://localhost:$DEMO_PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_cache_bypass \$http_upgrade;

    # Headers específicos para demo
    add_header X-Demo-Mode "true" always;
    add_header X-Content-Source "simulated" always;
    add_header X-Frame-Options "SAMEORIGIN" always;

    # CORS para demo
    add_header Access-Control-Allow-Origin "*" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, PATCH, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
}
EOF

# Incluir configuración demo en el sitio principal
if ! grep -q "include /etc/nginx/sites-available/$DEMO_NGINX_CONFIG" /etc/nginx/sites-available/default; then
    echo "    include /etc/nginx/sites-available/$DEMO_NGINX_CONFIG;" >> /etc/nginx/sites-available/default
    log "✅ Configuración demo añadida a Nginx"
fi

# Verificar configuración Nginx
nginx -t

if [[ $? -eq 0 ]]; then
    log "✅ Configuración Nginx válida"
    systemctl reload nginx
    log "✅ Nginx recargado"
else
    error "❌ Error en configuración Nginx"
    exit 1
fi

# 9. Verificaciones finales
log "🔍 Realizando verificaciones finales..."

sleep 3

# Verificar que PM2 está ejecutándose
if pm2 list | grep -q "$DEMO_PM2_NAME.*online"; then
    log "✅ PM2 demo online"
else
    error "❌ PM2 demo no está ejecutándose correctamente"
    pm2 logs "$DEMO_PM2_NAME" --lines 10
fi

# Verificar puerto
if netstat -ln | grep -q ":$DEMO_PORT "; then
    log "✅ Puerto $DEMO_PORT está en uso"
else
    warning "⚠️ Puerto $DEMO_PORT no parece estar en uso"
fi

# Test básico de conectividad
if curl -s "http://localhost:$DEMO_PORT/api/health" > /dev/null; then
    log "✅ API demo responde correctamente"
else
    warning "⚠️ API demo no responde en localhost:$DEMO_PORT"
fi

# 10. Guardar configuración PM2
pm2 save

log "💾 Configuración PM2 guardada"

# 11. Mostrar información final
echo ""
echo "🎉 =============================================="
echo "✅ MOVIEFLIX DEMO DESPLEGADO EXITOSAMENTE"
echo "=============================================="
echo ""
info "📍 URL Demo: https://$DEMO_DOMAIN/movieflix-demo"
info "🔧 Puerto: $DEMO_PORT"
info "📊 PM2 App: $DEMO_PM2_NAME"
info "🎭 Modo: DEMO_MODE=true"
info "🔐 Código acceso: 5202"
echo ""
echo "🛠️  COMANDOS ÚTILES:"
echo "   📊 Estado: pm2 status $DEMO_PM2_NAME"
echo "   📋 Logs: pm2 logs $DEMO_PM2_NAME"
echo "   🔄 Reinicio: pm2 restart $DEMO_PM2_NAME"
echo "   🛑 Parar: pm2 stop $DEMO_PM2_NAME"
echo ""
echo "🔍 TESTING:"
echo "   curl http://localhost:$DEMO_PORT/api/health"
echo "   curl https://$DEMO_DOMAIN/movieflix-demo/api/health"
echo ""
warning "⚠️  RECORDATORIO: Los datos en modo demo NO se persisten"
info "📚 Documentación: Ver README.md para más detalles"
echo ""

log "🎬 ¡Demo de MovieFlix listo para mostrar en tu portfolio!"
