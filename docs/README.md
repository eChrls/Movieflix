# 📚 MovieFlix - Documentación

Bienvenido a la documentación completa de MovieFlix, tu aplicación personal para gestionar películas y series.

## 📋 Índice

### 🚀 Inicio Rápido

- [Instalación](../README.md#-instalación)
- [Configuración](deployment/setup.md)
- [Primer uso](deployment/first-run.md)

### 🔧 Desarrollo

- [Arquitectura del proyecto](architecture.md)
- [API Reference](api/README.md)
- [Base de datos](database.md)
- [Frontend Components](frontend.md)

### 🌐 Deployment

- [Configuración del servidor](deployment/server-setup.md)
- [Nginx y SSL](deployment/nginx-ssl.md)
- [Monitoreo](deployment/monitoring.md)
- [Backups](deployment/backups.md)

### 🔒 Seguridad

- [Políticas de seguridad](../SECURITY.md)
- [Configuración de firewall](deployment/firewall.md)
- [Gestión de secretos](deployment/secrets.md)

### 🧪 Testing

- [Tests automatizados](testing.md)
- [Tests de integración](integration-testing.md)
- [Tests de rendimiento](performance-testing.md)

### 📊 Monitoreo y Logs

- [Configuración de logs](monitoring/logs.md)
- [Métricas de rendimiento](monitoring/metrics.md)
- [Alertas](monitoring/alerts.md)

## 🎯 Casos de Uso

### Usuario Final

- ✅ Gestionar colección personal de películas y series
- ✅ Crear múltiples perfiles familiares
- ✅ Filtrar y buscar contenido fácilmente
- ✅ Ver rankings de contenido favorito
- ✅ Interfaz responsiva para móviles

### Administrador

- ✅ Configurar y mantener el servidor
- ✅ Monitorear el rendimiento de la aplicación
- ✅ Gestionar backups y actualizaciones
- ✅ Configurar seguridad y accesos

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Database      │
│   React         │◄──►│   Node.js       │◄──►│   MySQL         │
│   Tailwind CSS  │    │   Express       │    │                 │
│   Mobile-First  │    │   REST API      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │    │   PM2 Process   │    │   File System   │
│   SSL/HTTPS     │    │   Management    │    │   Logs/Backups  │
│   Static Files  │    │   Auto-restart  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔄 Flujo de Desarrollo

1. **Desarrollo Local**

   ```bash
   npm run dev
   ```

2. **Testing**

   ```bash
   npm run test
   ```

3. **Build de Producción**

   ```bash
   npm run build
   ```

4. **Deployment**
   ```bash
   npm run deploy:local
   ```

## 🆘 Resolución de Problemas

### Problemas Comunes

#### 🔌 Error de Conexión a la Base de Datos

```bash
# Verificar estado de MySQL
sudo systemctl status mysql

# Verificar credenciales en .env
cat backend/.env | grep DB_
```

#### 🚫 API no Responde

```bash
# Verificar proceso de Node.js
pm2 list

# Ver logs
pm2 logs movieflix

# Reiniciar aplicación
pm2 restart movieflix
```

#### 🌐 Problema con Nginx

```bash
# Verificar configuración
sudo nginx -t

# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log

# Reiniciar Nginx
sudo systemctl restart nginx
```

## 📞 Soporte

### Documentación Técnica

- 📖 [API Documentation](api/README.md)
- 🏗️ [Architecture Guide](architecture.md)
- 🔧 [Deployment Guide](deployment/README.md)

### Recursos Externos

- 🟢 [Node.js Documentation](https://nodejs.org/docs/)
- ⚛️ [React Documentation](https://react.dev/)
- 🎨 [Tailwind CSS](https://tailwindcss.com/docs)
- 🐬 [MySQL Documentation](https://dev.mysql.com/doc/)

### Herramientas de Desarrollo

- 📝 [VS Code Extensions](development/vscode-extensions.md)
- 🔧 [Debugging Guide](development/debugging.md)
- 📊 [Performance Tools](development/performance.md)

---

**Última actualización**: 2025-01-01
**Versión**: 1.0.0
**Mantenido por**: MovieFlix Team
