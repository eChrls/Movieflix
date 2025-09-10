# MovieFlix - Guía de Instalación Paso a Paso

# Orange Pi 5 Plus - Ubuntu Server 22.04 LTS

## Paso 1: Preparación del Servidor

### Conectar al Orange Pi

```bash
# Desde Windows (PowerShell)
ssh user@192.168.1.50 -p 2222

# O usar la configuración existente
ssh casa74b@192.168.1.50 -p 2222
```

### Verificar sistema

```bash
# Información del sistema
uname -a
lsb_release -a
df -h
free -h
```

## Paso 2: Descargar e Instalar MovieFlix

### Opción A: Instalación Automática (Recomendada)

```bash
# Descargar script de instalación
wget https://raw.githubusercontent.com/tu-usuario/movieflix/main/scripts/install-ubuntu.sh

# Hacer ejecutable
chmod +x install-ubuntu.sh

# Ejecutar instalación
sudo ./install-ubuntu.sh
```

### Opción B: Instalación Manual

#### 1. Actualizar sistema

```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Instalar dependencias

```bash
sudo apt install -y curl wget git build-essential nginx mysql-server
```

#### 3. Instalar Node.js LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

#### 4. Configurar MySQL

```bash
sudo mysql_secure_installation

# Crear base de datos
sudo mysql -u root -p
```

```sql
CREATE DATABASE movieflix_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'movieflix_user'@'localhost' IDENTIFIED BY 'movieflix_secure_2025!';
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 5. Crear usuario del sistema

```bash
sudo useradd -r -s /bin/bash -d /opt/movieflix -m movieflix
```

#### 6. Crear estructura de directorios

```bash
sudo mkdir -p /opt/movieflix/{backend,frontend,logs,backups}
```

## Paso 3: Configurar el Proyecto

### 1. Clonar o copiar archivos

```bash
# Si tienes un repositorio
git clone https://github.com/tu-usuario/movieflix.git /tmp/movieflix
sudo cp -r /tmp/movieflix/* /opt/movieflix/

# O copiar archivos manualmente
sudo cp -r ./MovieFlix/* /opt/movieflix/
```

### 2. Instalar dependencias del backend

```bash
cd /opt/movieflix/backend
sudo -u movieflix npm install
```

### 3. Configurar variables de entorno

```bash
# Editar archivo .env
sudo nano /opt/movieflix/backend/.env
```

```env
# Configuración para tu Orange Pi
DB_HOST=localhost
DB_USER=movieflix_user
DB_PASSWORD=movieflix_secure_2025!
DB_NAME=movieflix_db

# APIs opcionales (conseguir en las páginas oficiales)
OMDB_API_KEY=tu_api_key_aqui
TMDB_API_KEY=tu_api_key_aqui

# Configuración del servidor
PORT=3001
NODE_ENV=production
CORS_ORIGIN=http://192.168.1.50:3000
```

### 4. Inicializar base de datos

```bash
cd /opt/movieflix/backend
sudo -u movieflix node scripts/init-db.js
```

### 5. Cargar datos iniciales

```bash
sudo -u movieflix node scripts/seed-data.js
```

### 6. Instalar dependencias del frontend

```bash
cd /opt/movieflix/frontend
sudo -u movieflix npm install
```

### 7. Construir frontend para producción

```bash
sudo -u movieflix npm run build
```

## Paso 4: Configurar Servicios

### 1. Crear servicios systemd

```bash
# Backend service
sudo tee /etc/systemd/system/movieflix-backend.service > /dev/null << 'EOF'
[Unit]
Description=MovieFlix Backend Service
After=network.target mysql.service

[Service]
Type=simple
User=movieflix
WorkingDirectory=/opt/movieflix/backend
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Frontend service
sudo tee /etc/systemd/system/movieflix-frontend.service > /dev/null << 'EOF'
[Unit]
Description=MovieFlix Frontend Service
After=network.target

[Service]
Type=simple
User=movieflix
WorkingDirectory=/opt/movieflix/frontend
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
```

### 2. Configurar Nginx

```bash
sudo tee /etc/nginx/sites-available/movieflix > /dev/null << 'EOF'
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
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Habilitar sitio
sudo ln -sf /etc/nginx/sites-available/movieflix /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Configurar firewall

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 3001/tcp
```

### 4. Configurar permisos

```bash
sudo chown -R movieflix:movieflix /opt/movieflix
sudo chmod -R 755 /opt/movieflix
```

## Paso 5: Iniciar Servicios

### 1. Recargar systemd

```bash
sudo systemctl daemon-reload
```

### 2. Iniciar y habilitar servicios

```bash
# Backend
sudo systemctl start movieflix-backend
sudo systemctl enable movieflix-backend

# Frontend
sudo systemctl start movieflix-frontend
sudo systemctl enable movieflix-frontend
```

### 3. Verificar estado

```bash
sudo systemctl status movieflix-backend
sudo systemctl status movieflix-frontend
```

## Paso 6: Verificación

### 1. Comprobar puertos

```bash
sudo netstat -tulpn | grep :300
```

### 2. Verificar logs

```bash
# Backend logs
sudo journalctl -u movieflix-backend -f

# Frontend logs
sudo journalctl -u movieflix-frontend -f
```

### 3. Probar aplicación

```bash
# Health check del backend
curl http://localhost:3001/api/health

# Acceder desde navegador
# http://192.168.1.50
```

## Paso 7: Configuración de APIs (Opcional)

### 1. OMDb API (1000 llamadas gratis/día)

1. Visita: http://www.omdbapi.com/apikey.aspx
2. Registrate con tu email
3. Recibirás un email con tu API key
4. Añádela al archivo .env: `OMDB_API_KEY=tu_key_aqui`

### 2. TMDb API (Límites generosos)

1. Visita: https://www.themoviedb.org/settings/api
2. Crea una cuenta
3. Solicita una API key
4. Añádela al archivo .env: `TMDB_API_KEY=tu_key_aqui`

### 3. Reiniciar backend después de configurar APIs

```bash
sudo systemctl restart movieflix-backend
```

## Comandos Útiles

### Monitorización

```bash
# Ver logs en tiempo real
sudo tail -f /opt/movieflix/logs/*.log

# Estado de servicios
sudo systemctl status movieflix-*

# Uso de recursos
htop
df -h
free -h
```

### Mantenimiento

```bash
# Reiniciar servicios
sudo systemctl restart movieflix-backend
sudo systemctl restart movieflix-frontend

# Actualizar código
cd /opt/movieflix
git pull
sudo systemctl restart movieflix-*

# Backup manual
sudo /opt/movieflix/backup.sh
```

### Troubleshooting

```bash
# Verificar conectividad de base de datos
sudo mysql -u movieflix_user -p movieflix_db

# Verificar configuración Nginx
sudo nginx -t

# Verificar puertos en uso
sudo netstat -tulpn | grep LISTEN

# Verificar logs de errores
sudo journalctl -u movieflix-backend --since "1 hour ago"
```

## Notas Importantes

1. **Seguridad**: Cambia todas las contraseñas por defecto
2. **Firewall**: Asegúrate de que UFW esté configurado correctamente
3. **Backup**: Configura backups automáticos con cron
4. **Monitorización**: Considera instalar herramientas como Netdata
5. **SSL**: Para producción, configura certificados SSL con Let's Encrypt

## Acceso Final

Una vez completada la instalación:

- **Frontend**: http://192.168.1.50 (o tu IP del Orange Pi)
- **API Backend**: http://192.168.1.50/api
- **Health Check**: http://192.168.1.50/api/health

¡MovieFlix estará listo para usar! 🎬
