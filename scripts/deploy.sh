#!/bin/bash

# ==========================================
# MovieFlix - Script de Deploy Público
# ==========================================
# Script para deployment en servidor de producción
# ⚠️  NO contiene credenciales sensibles

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables generales
PROJECT_NAME="MovieFlix"
PROJECT_DIR="/var/www/movieflix"
SERVICE_NAME="movieflix"
NGINX_SITE="movieflix"

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar que se ejecuta como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Este script debe ejecutarse como root (sudo)"
        exit 1
    fi
}

# Verificar dependencias
check_dependencies() {
    log "Verificando dependencias..."

    local dependencies=("git" "node" "npm" "mysql" "nginx" "pm2")
    local missing=()

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        error "Faltan dependencias: ${missing[*]}"
        error "Ejecuta primero: ./scripts/install-ubuntu.sh"
        exit 1
    fi

    log "✅ Todas las dependencias están instaladas"
}

# Crear directorio del proyecto
setup_project_directory() {
    log "Configurando directorio del proyecto..."

    if [ ! -d "$PROJECT_DIR" ]; then
        mkdir -p "$PROJECT_DIR"
        log "✅ Directorio creado: $PROJECT_DIR"
    else
        warning "Directorio ya existe: $PROJECT_DIR"
    fi

    # Cambiar permisos
    chown -R www-data:www-data "$PROJECT_DIR"
    chmod -R 755 "$PROJECT_DIR"
}

# Clonar o actualizar repositorio
deploy_code() {
    log "Desplegando código..."

    cd "$PROJECT_DIR"

    if [ ! -d ".git" ]; then
        info "Clonando repositorio..."
        # Nota: Reemplazar con la URL real del repositorio
        # git clone https://github.com/tu-usuario/movieflix.git .
        echo "⚠️  Copiar manualmente los archivos del proyecto a $PROJECT_DIR"
        echo "   O configurar el repositorio git remoto"
    else
        info "Actualizando repositorio..."
        git fetch origin
        git reset --hard origin/main
        log "✅ Código actualizado"
    fi
}

# Instalar dependencias
install_dependencies() {
    log "Instalando dependencias..."

    # Backend
    if [ -d "$PROJECT_DIR/backend" ]; then
        cd "$PROJECT_DIR/backend"
        npm install --production
        log "✅ Dependencias backend instaladas"
    fi

    # Frontend - construir para producción
    if [ -d "$PROJECT_DIR/frontend" ]; then
        cd "$PROJECT_DIR/frontend"
        npm install
        npm run build
        log "✅ Frontend construido para producción"
    fi
}

# Configurar variables de entorno
setup_environment() {
    log "Configurando variables de entorno..."

    local env_file="$PROJECT_DIR/backend/.env"

    if [ ! -f "$env_file" ]; then
        warning "Archivo .env no encontrado"
        echo "⚠️  Crear archivo $env_file con las variables necesarias:"
        echo "   DB_HOST=localhost"
        echo "   DB_USER=movieflix_user"
        echo "   DB_PASSWORD=password_segura"
        echo "   DB_NAME=movieflix_db"
        echo "   OMDB_API_KEY=tu_api_key"
        echo "   TMDB_API_KEY=tu_api_key"
        echo "   PORT=3001"
        echo "   NODE_ENV=production"
    else
        log "✅ Archivo .env encontrado"
    fi
}

# Configurar base de datos
setup_database() {
    log "Configurando base de datos..."

    if [ -f "$PROJECT_DIR/backend/scripts/init-db.js" ]; then
        cd "$PROJECT_DIR/backend"
        node scripts/init-db.js
        log "✅ Base de datos inicializada"

        if [ -f "scripts/seed-data.js" ]; then
            node scripts/seed-data.js
            log "✅ Datos de prueba cargados"
        fi
    else
        warning "Scripts de base de datos no encontrados"
    fi
}

# Configurar PM2
setup_pm2() {
    log "Configurando PM2..."

    # Detener aplicación existente si existe
    pm2 delete "$SERVICE_NAME" 2>/dev/null || true

    # Iniciar aplicación
    cd "$PROJECT_DIR/backend"
    pm2 start server.js --name "$SERVICE_NAME" --env production

    # Guardar configuración PM2
    pm2 save
    pm2 startup systemd -u www-data --hp /var/www

    log "✅ Servicio PM2 configurado"
}

# Configurar Nginx
setup_nginx() {
    log "Configurando Nginx..."

    local nginx_config="/etc/nginx/sites-available/$NGINX_SITE"

    cat > "$nginx_config" << 'EOF'
server {
    listen 80;
    server_name localhost;

    # Servir archivos estáticos del frontend
    root /var/www/movieflix/frontend/build;
    index index.html index.htm;

    # Configuración para SPA (Single Page Application)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy para API backend
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Configuración de archivos estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
EOF

    # Habilitar sitio
    ln -sf "$nginx_config" "/etc/nginx/sites-enabled/$NGINX_SITE"

    # Remover sitio por defecto si existe
    rm -f /etc/nginx/sites-enabled/default

    # Verificar configuración
    nginx -t

    # Reiniciar Nginx
    systemctl restart nginx
    systemctl enable nginx

    log "✅ Nginx configurado y reiniciado"
}

# Configurar firewall
setup_firewall() {
    log "Configurando firewall..."

    # Permitir SSH, HTTP, HTTPS
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp

    # Habilitar firewall
    ufw --force enable

    log "✅ Firewall configurado"
}

# Verificar servicios
verify_deployment() {
    log "Verificando deployment..."

    # Verificar PM2
    if pm2 list | grep -q "$SERVICE_NAME"; then
        log "✅ Servicio PM2 ejecutándose"
    else
        error "❌ Servicio PM2 no encontrado"
        exit 1
    fi

    # Verificar Nginx
    if systemctl is-active --quiet nginx; then
        log "✅ Nginx ejecutándose"
    else
        error "❌ Nginx no está ejecutándose"
        exit 1
    fi

    # Verificar MySQL
    if systemctl is-active --quiet mysql; then
        log "✅ MySQL ejecutándose"
    else
        error "❌ MySQL no está ejecutándose"
        exit 1
    fi

    # Test de conectividad
    sleep 5
    if curl -f http://localhost:3001/api/health > /dev/null 2>&1; then
        log "✅ API respondiendo correctamente"
    else
        warning "⚠️  API no responde en localhost:3001"
    fi

    if curl -f http://localhost/ > /dev/null 2>&1; then
        log "✅ Frontend accesible"
    else
        warning "⚠️  Frontend no accesible en localhost"
    fi
}

# Mostrar información final
show_final_info() {
    log "🎉 Deployment completado!"
    echo
    echo "============================================"
    echo "           INFORMACIÓN DE DEPLOYMENT"
    echo "============================================"
    echo
    echo "📁 Proyecto ubicado en: $PROJECT_DIR"
    echo "🌐 Aplicación disponible en: http://localhost"
    echo "🔧 API disponible en: http://localhost/api"
    echo "📊 Monitoreo PM2: pm2 monit"
    echo
    echo "🔧 Comandos útiles:"
    echo "   pm2 list                    - Ver servicios"
    echo "   pm2 logs $SERVICE_NAME      - Ver logs"
    echo "   pm2 restart $SERVICE_NAME   - Reiniciar"
    echo "   systemctl status nginx      - Estado Nginx"
    echo "   systemctl status mysql      - Estado MySQL"
    echo
    echo "📝 Próximos pasos:"
    echo "   1. Configurar dominio (DuckDNS)"
    echo "   2. Instalar certificado SSL"
    echo "   3. Configurar backups automáticos"
    echo
    echo "============================================"
}

# Función principal
main() {
    log "🚀 Iniciando deployment de $PROJECT_NAME"

    check_root
    check_dependencies
    setup_project_directory
    deploy_code
    install_dependencies
    setup_environment
    setup_database
    setup_pm2
    setup_nginx
    setup_firewall
    verify_deployment
    show_final_info

    log "✨ Deployment completado exitosamente!"
}

# Ejecutar función principal si el script se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
