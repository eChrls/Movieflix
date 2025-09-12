# 🎭 MovieFlix Demo Mode

**Versión de demostración interactiva para portfolio**

## 🎯 Descripción

El modo demo de MovieFlix permite mostrar toda la funcionalidad de la aplicación utilizando datos simulados en memoria, sin necesidad de una base de datos real. Perfecto para portfolios y demostraciones.

## ✨ Características

### 🔒 Seguridad Total

- ✅ Los datos son simulados y se almacenan solo en memoria
- ✅ No hay conexión a base de datos MySQL real
- ✅ Rate limiting para evitar abuso (200 requests/15min)
- ✅ Sanitización automática de inputs
- ✅ Headers de seguridad implementados

### 🎯 Funcionalidad Completa

- ✅ Los usuarios pueden agregar, editar y eliminar películas
- ✅ Todas las funciones funcionan normalmente
- ✅ Interface idéntica a la aplicación real
- ✅ Banner informativo que explica que es una demo
- ✅ Validación de duplicados
- ✅ Sistema de búsqueda con sugerencias
- ✅ Top 3 películas y series

### ⚡ Implementación Sencilla

- ✅ Solo necesitas agregar la variable `DEMO_MODE=true`
- ✅ Misma base de código, sin duplicación
- ✅ Deploy independiente en el mismo servidor
- ✅ URL profesional: `tudominio.com/movieflix-demo`

## 🚀 Instalación y Configuración

### 1. Configurar Variables de Entorno

```bash
# Backend (.env)
DEMO_MODE=true
DEMO_CODE=5202
DEMO_PASSWORD=demo2024
PORT=3002

# Frontend (.env.demo)
REACT_APP_DEMO_MODE=true
REACT_APP_API_BASE_URL=/api
```

### 2. Instalar Dependencias

```bash
# Backend
cd backend
npm install express-rate-limit

# Frontend - no requiere dependencias adicionales
cd frontend
# Los archivos ya están creados
```

### 3. Deploy Automático

```bash
# En el servidor (Orange Pi)
chmod +x scripts/deploy-demo.sh
./scripts/deploy-demo.sh
```

## 🛠️ Uso Manual

### Modo Desarrollo Local

```bash
# Terminal 1: Backend Demo
cd backend
DEMO_MODE=true PORT=3002 node server.js

# Terminal 2: Frontend Demo
cd frontend
REACT_APP_DEMO_MODE=true npm start
```

### Modo Producción

```bash
# Usar el script automático
./scripts/deploy-demo.sh

# O manualmente:
cd frontend
REACT_APP_DEMO_MODE=true npm run build
pm2 start ecosystem.demo.config.js
```

## 📊 Datos Demo Incluidos

### 👥 Perfiles

- Demo User 👤
- Familia 👨‍👩‍👧‍👦
- Niños 🧒

### 🎬 Contenido

- **Películas**: Inception, The Dark Knight, Interstellar, Dune
- **Series**: Breaking Bad, The Mandalorian
- **Estados**: Pendientes y Vistas
- **Plataformas**: Netflix, HBO Max, Disney+, Amazon Prime, Apple TV+

### 🔍 Funciones Disponibles

- ✅ Agregar contenido (simulado)
- ✅ Editar información
- ✅ Marcar como visto/pendiente
- ✅ Eliminar contenido
- ✅ Búsqueda con sugerencias
- ✅ Filtros por tipo/plataforma
- ✅ Top 3 por categoría

## 🌐 URLs de Acceso

### Desarrollo

- **Frontend**: http://localhost:3000 (con REACT_APP_DEMO_MODE=true)
- **Backend**: http://localhost:3002/api/health
- **Código acceso**: `5202`

### Producción

- **URL Principal**: https://home-movieflix.duckdns.org/movieflix-demo
- **API Health**: https://home-movieflix.duckdns.org/movieflix-demo/api/health
- **Código acceso**: `5202`

## 🔧 Gestión PM2

```bash
# Estado
pm2 status movieflix-demo

# Logs en tiempo real
pm2 logs movieflix-demo

# Reiniciar
pm2 restart movieflix-demo

# Detener
pm2 stop movieflix-demo

# Eliminar
pm2 delete movieflix-demo
```

## 🛡️ Medidas de Seguridad

### Rate Limiting

- **Ventana**: 15 minutos
- **Límite**: 200 requests por IP
- **Aplicado a**: Todas las rutas `/api/*`

### Sanitización

- Inputs limitados a 100 caracteres
- Eliminación de caracteres peligrosos (`<>`)
- Payloads limitados a 2KB máximo

### Headers de Seguridad

```
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Demo-Mode: true
X-Demo-Warning: This is a demonstration. Data is not persistent.
```

## 🚨 Limitaciones Importantes

### ⚠️ Datos No Persistentes

- Los cambios NO se guardan al reiniciar
- Cada sesión comienza con datos predefinidos
- No hay sincronización entre usuarios

### ⚠️ Funcionalidad Limitada

- No conecta a APIs externas reales (simuladas)
- No hay sistema de usuarios real
- Búsquedas limitadas a contenido predefinido

### ⚠️ Rendimiento

- Limitado a 200 requests por IP cada 15 minutos
- Datos almacenados en memoria (reinicio = reset)
- Un solo proceso PM2 para demo

## 🎨 Personalización

### Modificar Datos Demo

Edita `backend/middleware/demoMode.js`:

```javascript
const demoData = {
  content: [
    // Agregar tus películas/series demo aquí
  ],
  profiles: [
    // Personalizar perfiles demo
  ],
};
```

### Personalizar Banner

Edita `frontend/src/components/DemoNotice.js`:

```javascript
// Cambiar mensaje, colores, enlaces, etc.
```

## 📈 Monitoreo

### Logs del Sistema

```bash
# Logs específicos demo
tail -f logs/demo-combined.log

# Logs de Nginx
tail -f /var/log/nginx/access.log | grep movieflix-demo

# Logs PM2
pm2 logs movieflix-demo --lines 50
```

### Métricas

- Requests por minuto en logs
- Estado de memoria con `pm2 monit`
- Errores en logs de error específicos

## 🤝 Soporte

### Troubleshooting Común

**❌ Error 502 Bad Gateway**

```bash
# Verificar que PM2 está corriendo
pm2 status movieflix-demo
pm2 restart movieflix-demo
```

**❌ Datos no aparecen**

```bash
# Verificar modo demo activo
curl http://localhost:3002/api/health
# Debe mostrar "mode": "DEMO"
```

**❌ Banner no aparece**

```bash
# Verificar variables frontend
grep REACT_APP_DEMO_MODE .env.demo
# Debe ser "true"
```

### Contacto

- **GitHub**: https://github.com/eChrls/Movieflix
- **Issues**: https://github.com/eChrls/Movieflix/issues

---

_🎭 MovieFlix Demo Mode - Mostrando el futuro del entretenimiento personal_
