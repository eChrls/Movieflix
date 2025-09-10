# ==========================================

# MovieFlix - Security Policy

# ==========================================

## Versiones Soportadas

Usamos este documento para informar sobre qué versiones de MovieFlix están actualmente soportadas con actualizaciones de seguridad.

| Versión | Soportada          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reportar una Vulnerabilidad

Si descubres una vulnerabilidad de seguridad en MovieFlix, por favor reportala de manera responsable.

### Proceso de Reporte

1. **NO** abras un issue público para vulnerabilidades de seguridad
2. Envía un email a: [security@movieflix.local] con los detalles
3. Incluye la mayor información posible:
   - Descripción de la vulnerabilidad
   - Pasos para reproducir
   - Impacto potencial
   - Versión afectada

### Qué Esperar

- **Confirmación**: Dentro de 48 horas
- **Evaluación inicial**: Dentro de 1 semana
- **Corrección**: Dentro de 30 días (dependiendo de la severidad)
- **Divulgación**: Coordinaremos la divulgación pública

### Vulnerabilidades en Dependencias

Para vulnerabilidades en dependencias de terceros:

```bash
# Revisar vulnerabilidades
npm audit

# Corregir automáticamente
npm audit fix

# Actualizar dependencias críticas
npm update
```

## Prácticas de Seguridad

### Configuración del Servidor

- Mantener Ubuntu Server actualizado
- Usar firewall UFW configurado
- Acceso SSH solo con llaves
- Usuarios con privilegios mínimos

### Aplicación

- Variables de entorno para secretos
- Validación de entrada estricta
- Headers de seguridad HTTP
- Rate limiting implementado
- CORS configurado apropiadamente

### Base de Datos

- Usuario específico con permisos mínimos
- Contraseñas fuertes
- Conexiones locales únicamente
- Backups encriptados

## Recursos de Seguridad

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Checklist](https://blog.risingstack.com/node-js-security-checklist/)
- [React Security Best Practices](https://snyk.io/blog/10-react-security-best-practices/)

---

**Fecha de última actualización**: 2025-01-01
**Versión del documento**: 1.0
