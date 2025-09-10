# 🎬 MovieFlix

Una aplicación web moderna para gestionar tu colección personal de películas y series, inspirada en la experiencia de Netflix.

![Status](https://img.shields.io/badge/Status-Development-orange)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![License](https://img.shields.io/badge/License-Private-red)

## ✨ Características

- **🌙 Tema Oscuro Profesional**: Diseño inspirado en Netflix
- **📱 Responsive Mobile-First**: Optimizado para dispositivos móviles
- **👥 Sistema de Perfiles**: Múltiples perfiles sin autenticación
- **🔍 Búsqueda Avanzada**: Filtros por género, plataforma y tipo
- **⭐ Rankings Dinámicos**: Top 3 de películas y series
- **🎭 Gestión Completa**: Añadir, editar y eliminar contenido
- **🔗 Integración APIs**: OMDb y TMDb para información automática
- **🏷️ Clasificación Inteligente**: Sistema de géneros y plataformas

## 🛠️ Stack Tecnológico

### Backend

- **Node.js 18 LTS** - Runtime de JavaScript
- **Express 4.18.2** - Framework web
- **MySQL 8.0** - Base de datos
- **Helmet.js** - Seguridad HTTP

### Frontend

- **React 18.2.0** - Librería de UI
- **Tailwind CSS** - Framework de estilos
- **Lucide React** - Iconografía

### Infraestructura

- **Ubuntu Server 22.04** - Sistema operativo
- **Nginx** - Proxy reverso
- **PM2** - Gestor de procesos
- **DuckDNS** - DNS dinámico

## 🚀 Instalación

### Prerrequisitos

- Ubuntu Server 22.04 LTS
- Node.js 18 LTS
- MySQL 8.0
- Nginx

### Instalación Automatizada

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/movieflix.git
cd movieflix

# Ejecutar script de instalación
chmod +x scripts/install-ubuntu.sh
sudo ./scripts/install-ubuntu.sh
```

### Instalación Manual

```bash
# Instalar dependencias del backend
cd backend
npm install

# Instalar dependencias del frontend
cd ../frontend
npm install

# Inicializar base de datos
cd ../backend
node scripts/init-db.js

# Cargar datos de ejemplo
node scripts/seed-data.js
```

## ⚙️ Configuración

### Variables de Entorno

Crear archivo `.env` en la carpeta `backend`:

```env
# Base de datos
DB_HOST=localhost
DB_USER=movieflix_user
DB_PASSWORD=tu_password_segura
DB_NAME=movieflix_db
DB_PORT=3306

# APIs externas
OMDB_API_KEY=tu_api_key
TMDB_API_KEY=tu_api_key

# Servidor
PORT=3001
NODE_ENV=production
```

### Base de Datos

```sql
-- Crear usuario y base de datos
CREATE DATABASE movieflix_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'movieflix_user'@'localhost' IDENTIFIED BY 'password_segura';
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'localhost';
FLUSH PRIVILEGES;
```

## 🎯 Uso

### Desarrollo

```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend
cd frontend
npm start
```

### Producción

```bash
# Construir frontend
cd frontend
npm run build

# Iniciar servicios con PM2
pm2 start ecosystem.config.js
```

## 📁 Estructura del Proyecto

```
MovieFlix/
├── backend/                 # API REST con Express
│   ├── server.js           # Servidor principal
│   ├── scripts/            # Scripts de base de datos
│   └── package.json        # Dependencias backend
├── frontend/               # Aplicación React
│   ├── src/
│   │   ├── App.js         # Componente principal
│   │   └── index.js       # Punto de entrada
│   ├── public/            # Archivos estáticos
│   └── package.json       # Dependencias frontend
├── scripts/               # Scripts de instalación
├── docs/                  # Documentación
└── README.md             # Este archivo
```

## 🔧 API Endpoints

### Perfiles

- `GET /api/profiles` - Listar perfiles
- `POST /api/profiles` - Crear perfil
- `PUT /api/profiles/:id` - Actualizar perfil
- `DELETE /api/profiles/:id` - Eliminar perfil

### Contenido

- `GET /api/content` - Listar contenido
- `POST /api/content` - Añadir contenido
- `PUT /api/content/:id` - Actualizar contenido
- `DELETE /api/content/:id` - Eliminar contenido

### Utilidades

- `GET /api/platforms` - Listar plataformas
- `GET /api/genres` - Listar géneros
- `GET /api/search/:query` - Búsqueda externa

## 🌐 Despliegue

La aplicación está configurada para desplegarse en:

- **Dominio**: `home-movieflix.duckdns.org`
- **Puerto Backend**: 3001
- **Puerto Frontend**: 3000 (desarrollo) / 80,443 (producción)

### Nginx

```nginx
server {
    listen 80;
    server_name home-movieflix.duckdns.org;

    # Redirigir a HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name home-movieflix.duckdns.org;

    # Servir frontend
    root /path/to/movieflix/frontend/build;
    index index.html;

    # Proxy para API
    location /api/ {
        proxy_pass http://localhost:3001;
    }
}
```

## 🔒 Seguridad

- **Helmet.js**: Headers de seguridad HTTP
- **Rate Limiting**: Limitación de peticiones
- **CORS**: Control de acceso cruzado
- **Input Validation**: Validación de datos
- **Error Boundaries**: Manejo de errores

## 📊 Características Técnicas

### Performance

- **Lazy Loading**: Carga diferida de componentes
- **Optimized Queries**: Consultas de base de datos optimizadas
- **Caching**: Cache de respuestas API

### Responsive Design

- **Mobile-First**: Diseño prioritario para móviles
- **Breakpoints**: sm(640px), md(768px), lg(1024px), xl(1280px)
- **Touch-Friendly**: Interfaz optimizada para touch

## 🤝 Contribución

Este es un proyecto privado. Para contribuir:

1. Fork del repositorio
2. Crear rama de feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit de cambios (`git commit -am 'Añadir nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crear Pull Request

## 📝 Licencia

Este proyecto es privado y propietario. Todos los derechos reservados.

## 🐛 Reporte de Bugs

Para reportar bugs o solicitar características:

1. Usar el sistema de Issues de GitHub
2. Incluir descripción detallada
3. Pasos para reproducir
4. Capturas de pantalla si aplica

## 📞 Soporte

- **Email**: ecom.jct@gmail.com
- **Issues**: GitHub Issues
- **Documentación**: `/docs` folder

## 🔄 Versionado

Utilizamos [SemVer](http://semver.org/) para el versionado. Para las versiones disponibles, consulta los [tags del repositorio](https://github.com/tu-usuario/movieflix/tags).

### Changelog

#### v1.0.0 (2025-01-01)

- ✨ Lanzamiento inicial
- 🎬 Sistema completo de gestión de películas y series
- 👥 Sistema de perfiles múltiples
- 📱 Diseño responsive mobile-first
- 🔒 Implementación de seguridad básica
- 🌙 Tema oscuro profesional

---

**MovieFlix** - Tu colección personal de entretenimiento 🎬✨
