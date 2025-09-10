#!/bin/bash

# MovieFlix - Script de instalación completa para Orange Pi 5 Plus
# Ubuntu Server 22.04 LTS ARM64
# Versión: 1.0.0

set -e  # Exit on any error

echo "🎬 MovieFlix - Instalación Automática"
echo "===================================="
echo "📅 $(date)"
echo "🖥️  Sistema: $(uname -a)"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables de configuración
PROJECT_DIR="/opt/movieflix"
SERVICE_USER="movieflix"
DB_NAME="movieflix_db"
DB_USER="movieflix_user"
DB_PASSWORD="movieflix_secure_2025!"
NODE_VERSION="18"

# Funciones helper
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar si se ejecuta como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Este script necesita ejecutarse como root"
        echo "Ejecuta: sudo $0"
        exit 1
    fi
}

# Verificar conectividad
check_connectivity() {
    print_step "Verificando conectividad a internet..."
    if ! ping -c 1 google.com &> /dev/null; then
        print_error "No hay conexión a internet"
        exit 1
    fi
    print_status "Conectividad verificada"
}

# Actualizar sistema
update_system() {
    print_step "Actualizando el sistema..."
    apt update && apt upgrade -y
    print_status "Sistema actualizado"
}

# Instalar dependencias del sistema
install_dependencies() {
    print_step "Instalando dependencias del sistema..."
    apt install -y \
        curl \
        wget \
        git \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        nginx \
        ufw \
        htop \
        tree \
        unzip
    print_status "Dependencias instaladas"
}

# Instalar Node.js LTS
install_nodejs() {
    print_step "Instalando Node.js ${NODE_VERSION} LTS..."

    # Instalar Node.js desde NodeSource
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
    apt install -y nodejs

    # Verificar instalación
    node_version=$(node --version)
    npm_version=$(npm --version)
    print_status "Node.js instalado: $node_version"
    print_status "npm instalado: $npm_version"

    # Instalar PM2 globalmente para gestión de procesos
    npm install -g pm2
    print_status "PM2 instalado para gestión de procesos"
}

# Instalar y configurar MySQL
install_mysql() {
    print_step "Instalando MySQL Server..."

    # Instalar MySQL
    apt install -y mysql-server

    # Iniciar y habilitar MySQL
    systemctl start mysql
    systemctl enable mysql

    print_status "MySQL instalado y configurado"
}

# Configurar MySQL
configure_mysql() {
    print_step "Configurando base de datos MySQL..."

    # Configurar MySQL de forma no interactiva
    mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

    print_status "Base de datos configurada"
    print_status "Base de datos: ${DB_NAME}"
    print_status "Usuario: ${DB_USER}"
}

# Crear usuario del sistema
create_system_user() {
    print_step "Creando usuario del sistema..."

    if ! id "$SERVICE_USER" &>/dev/null; then
        useradd -r -s /bin/bash -d $PROJECT_DIR -m $SERVICE_USER
        print_status "Usuario $SERVICE_USER creado"
    else
        print_status "Usuario $SERVICE_USER ya existe"
    fi
}

# Crear estructura del proyecto
create_project_structure() {
    print_step "Creando estructura del proyecto..."

    # Crear directorios
    mkdir -p $PROJECT_DIR/{backend,frontend,logs,backups}

    print_status "Estructura de directorios creada en $PROJECT_DIR"
}

# Configurar firewall
configure_firewall() {
    print_step "Configurando firewall UFW..."

    # Configurar UFW
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing

    # Permitir puertos necesarios
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw allow 3000/tcp comment 'MovieFlix Frontend'
    ufw allow 3001/tcp comment 'MovieFlix Backend'

    print_status "Firewall configurado"
}

# Configurar Nginx
configure_nginx() {
    print_step "Configurando Nginx..."

    # Crear configuración para MovieFlix
    cat > /etc/nginx/sites-available/movieflix << 'EOF'
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

    # Habilitar sitio
    ln -sf /etc/nginx/sites-available/movieflix /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default

    # Verificar configuración
    nginx -t
    systemctl reload nginx

    print_status "Nginx configurado y recargado"
}

# Crear servicios systemd
create_systemd_services() {
    print_step "Creando servicios systemd..."

    # Servicio para backend
    cat > /etc/systemd/system/movieflix-backend.service << EOF
[Unit]
Description=MovieFlix Backend Service
After=network.target mysql.service
Wants=mysql.service

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$PROJECT_DIR/backend
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=DB_HOST=localhost
Environment=DB_USER=$DB_USER
Environment=DB_PASSWORD=$DB_PASSWORD
Environment=DB_NAME=$DB_NAME
Environment=PORT=3001

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$PROJECT_DIR

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=movieflix-backend

[Install]
WantedBy=multi-user.target
EOF

    # Servicio para frontend
    cat > /etc/systemd/system/movieflix-frontend.service << EOF
[Unit]
Description=MovieFlix Frontend Service
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$PROJECT_DIR/frontend
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$PROJECT_DIR

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=movieflix-frontend

[Install]
WantedBy=multi-user.target
EOF

    # Recargar systemd
    systemctl daemon-reload

    print_status "Servicios systemd creados"
}

# Configurar permisos
set_permissions() {
    print_step "Configurando permisos..."

    chown -R $SERVICE_USER:$SERVICE_USER $PROJECT_DIR
    chmod -R 755 $PROJECT_DIR

    # Permisos especiales para logs
    chmod 750 $PROJECT_DIR/logs
    chmod 750 $PROJECT_DIR/backups

    print_status "Permisos configurados"
}

# Crear script de backup
create_backup_script() {
    print_step "Creando script de backup..."

    cat > $PROJECT_DIR/backup.sh << 'EOF'
#!/bin/bash

# MovieFlix Backup Script
BACKUP_DIR="/opt/movieflix/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="movieflix_db"
DB_USER="movieflix_user"

# Crear directorio de backup
mkdir -p "$BACKUP_DIR/$DATE"

# Backup de base de datos
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > "$BACKUP_DIR/$DATE/database.sql"

# Backup de configuraciones
cp -r /opt/movieflix/backend/.env "$BACKUP_DIR/$DATE/" 2>/dev/null || true

# Comprimir backup
cd $BACKUP_DIR
tar -czf "movieflix_backup_$DATE.tar.gz" "$DATE"
rm -rf "$DATE"

# Limpiar backups antiguos (mantener últimos 7 días)
find $BACKUP_DIR -name "movieflix_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completado: movieflix_backup_$DATE.tar.gz"
EOF

    chmod +x $PROJECT_DIR/backup.sh
    chown $SERVICE_USER:$SERVICE_USER $PROJECT_DIR/backup.sh

    print_status "Script de backup creado"
}

# Función principal
main() {
    echo "🚀 Iniciando instalación de MovieFlix..."
    echo ""

    check_root
    check_connectivity
    update_system
    install_dependencies
    install_nodejs
    install_mysql
    configure_mysql
    create_system_user
    create_project_structure
    configure_firewall
    configure_nginx
    create_systemd_services
    set_permissions
    create_backup_script

    echo ""
    echo "🎉 ¡Instalación de MovieFlix completada!"
    echo ""
    echo "📋 Información de la instalación:"
    echo "   • Directorio del proyecto: $PROJECT_DIR"
    echo "   • Usuario del sistema: $SERVICE_USER"
    echo "   • Base de datos: $DB_NAME"
    echo "   • Usuario de BD: $DB_USER"
    echo "   • Frontend: http://localhost:3000"
    echo "   • Backend: http://localhost:3001"
    echo ""
    echo "📝 Próximos pasos:"
    echo "   1. Copia los archivos del proyecto a $PROJECT_DIR"
    echo "   2. Instala dependencias:"
    echo "      cd $PROJECT_DIR/backend && npm install"
    echo "      cd $PROJECT_DIR/frontend && npm install"
    echo "   3. Inicializa la base de datos:"
    echo "      cd $PROJECT_DIR/backend && node scripts/init-db.js"
    echo "   4. Carga datos iniciales:"
    echo "      node scripts/seed-data.js"
    echo "   5. Inicia los servicios:"
    echo "      systemctl start movieflix-backend"
    echo "      systemctl start movieflix-frontend"
    echo "      systemctl enable movieflix-backend"
    echo "      systemctl enable movieflix-frontend"
    echo ""
    echo "🔧 Para obtener APIs keys gratuitas:"
    echo "   • OMDb API: http://www.omdbapi.com/apikey.aspx"
    echo "   • TMDb API: https://www.themoviedb.org/settings/api"
    echo "   Añádelas al archivo $PROJECT_DIR/backend/.env"
    echo ""
    echo "📊 Monitorización:"
    echo "   • Logs backend: journalctl -u movieflix-backend -f"
    echo "   • Logs frontend: journalctl -u movieflix-frontend -f"
    echo "   • Estado servicios: systemctl status movieflix-*"
    echo ""
    print_status "¡MovieFlix está listo para configurar!"
}

# Ejecutar función principal
main "$@"
