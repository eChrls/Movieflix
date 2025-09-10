# 📋 MovieFlix - Guía de Inserción Segura de Contenido

## 🎯 Objetivo

Agregar contenido faltante (películas y series) a la base de datos MovieFlix de forma segura y profesional, evitando duplicados y manteniendo la integridad de los datos.

## 🛡️ Características de Seguridad

### ✅ **Protecciones Implementadas**

- **Transacciones**: Rollback automático en caso de error
- **Verificación de duplicados**: No inserta contenido existente
- **Integridad referencial**: Mantiene las relaciones entre tablas
- **Backup automático**: Crea respaldo antes de los cambios
- **Validación de datos**: Verifica estructura y datos requeridos
- **Logs detallados**: Registro completo de operaciones

### 🔒 **Prevención de Riesgos**

- No modifica datos existentes
- No elimina contenido
- Verifica conexión antes de proceder
- Usa procedimientos almacenados temporales
- Validación de estructura de tablas

## 📁 Archivos Creados

### 1. `add-missing-content-safe.sql`

**Script SQL principal** - Adaptado específicamente a tu estructura de base de datos

- ✅ Compatible con tabla `content` (no `titles`)
- ✅ Maneja géneros como JSON (no tabla separada)
- ✅ Requiere `profile_id` (usa perfil "Home")
- ✅ Mapeo correcto de plataformas

### 2. `safe-execute.sh` (Linux/Mac)

**Script de ejecución segura con backup automático**

- Verifica dependencias y conexión
- Crea backup automático con timestamp
- Ejecuta SQL con logging completo
- Restaura automáticamente en caso de error

### 3. `verify-and-execute.bat` (Windows)

**Script de verificación y ejecución para Windows**

- Verifica estado actual de la base de datos
- Detecta posibles duplicados
- Muestra resumen detallado
- Permite ejecución opcional

## 🚀 Instrucciones de Uso

### **Opción 1: Verificación Previa (Recomendado)**

```cmd
# En Windows
cd MovieFlix\scripts
verify-and-execute.bat
```

Este script:

1. Verifica la conexión a la base de datos
2. Muestra el estado actual
3. Detecta posibles duplicados
4. Te permite decidir si continuar
5. Ejecuta el script SQL si confirmas

### **Opción 2: Ejecución Directa con Backup**

```bash
# En Linux/Mac (requiere Git Bash en Windows)
cd MovieFlix/scripts
chmod +x safe-execute.sh
./safe-execute.sh
```

### **Opción 3: Ejecución Manual (Solo si eres experto)**

```cmd
# Asegúrate de tener backup manual primero
mysql -h localhost -u movieflix_user -p movieflix_db < scripts\add-missing-content-safe.sql
```

## 📊 Contenido que se Agregará

### **Series (12 títulos)**

- The Pitt (2025) - HBO
- When They See Us (2019) - Netflix
- La Maravillosa Sra. Maisel (2017) - Prime Video
- This Is Us (2016) - Prime Video
- Dopesick (2021) - Disney+
- The Expanse (2015) - Prime Video
- Billions (2016) - Prime Video
- High Maintenance (2016) - HBO
- Wild Wild Country (2018) - Netflix
- Tokyo Vice (2022) - HBO
- The Morning Show (2019) - Apple TV+
- Slow Horses (2022) - Apple TV+

### **Películas (19 títulos)**

- El Hombre que Mató a Liberty Valance (1962) - Disney+
- Centauros del Desierto (1956) - Sin plataforma
- Solo Ante el Peligro (1952) - Sin plataforma
- Perfect Blue (1997) - Sin plataforma
- Castle in the Sky (1986) - Sin plataforma
- The Tale of the Princess Kaguya (2013) - Sin plataforma
- Porco Rosso (1992) - Sin plataforma
- Doctor Zhivago (1965) - HBO
- Trece Vidas (2022) - Prime Video
- La Cinta Blanca (2009) - Sin plataforma
- The Florida Project (2017) - Netflix
- Contratiempo (2016) - Netflix
- Cría Cuervos (1976) - Filmin
- Que Dios Nos Perdone (2016) - Netflix
- Tetris (2023) - Apple TV+
- First Blood (1982) - Prime Video
- Dredd (2012) - Prime Video
- Coherence (2013) - Sin plataforma
- La Hora del Diablo (2021) - Sin plataforma

## ⚠️ Consideraciones Importantes

### **Antes de Ejecutar**

1. **Hacer backup manual** (por seguridad extra)
2. **Cerrar la aplicación MovieFlix** si está ejecutándose
3. **Verificar espacio en disco** suficiente
4. **Confirmar credenciales** de base de datos

### **Durante la Ejecución**

- No interrumpir el proceso
- Revisar los mensajes de log
- Verificar que no hay errores

### **Después de Ejecutar**

1. **Verificar resultados** con los reportes generados
2. **Reiniciar servidor MovieFlix** si estaba ejecutándose
3. **Probar la aplicación** para confirmar que aparece el nuevo contenido
4. **Guardar backup** en lugar seguro

## 🐛 Solución de Problemas

### **Error de Conexión**

```
❌ No se puede conectar a la base de datos
```

**Solución:**

- Verificar que MySQL esté ejecutándose
- Comprobar credenciales en `.env`
- Verificar puerto (3306)

### **Error de Permisos**

```
❌ Access denied for user
```

**Solución:**

- Verificar usuario y contraseña
- Confirmar permisos de escritura en la base de datos

### **Error de Integridad**

```
❌ Foreign key constraint fails
```

**Solución:**

- Verificar que existe el perfil "Home"
- Confirmar estructura de tablas

### **Duplicados Detectados**

```
⚠️ Ya existe contenido similar
```

**Nota:** Es normal, el script evitará insertar duplicados automáticamente.

## 📈 Verificación de Resultados

Después de la ejecución, el script mostrará:

```sql
-- Contenido insertado por tipo
Type     | Total | Rating Promedio
---------|-------|----------------
series   |   12  |      8.3
movie    |   19  |      7.6

-- Distribución por plataformas
Plataforma    | Contenido Total | Insertado Hoy
--------------|-----------------|---------------
Netflix       |       45        |       4
Prime Video   |       38        |       6
HBO           |       29        |       4
...

-- Verificación de integridad
Sin Perfil | Sin Título | Sin Año | Tipo Inválido
-----------|------------|---------|---------------
    0      |     0      |    0    |       0
```

## 🔄 Rollback (En caso de problemas)

Si algo sale mal, puedes restaurar desde el backup:

```bash
# Restaurar backup automático
mysql -h localhost -u movieflix_user -p movieflix_db < backups/movieflix_backup_YYYYMMDD_HHMMSS.sql

# O usar backup manual
mysql -h localhost -u movieflix_user -p movieflix_db < tu_backup_manual.sql
```

## 📞 Contacto y Soporte

Si encuentras algún problema:

1. Revisa los logs generados
2. Verifica que seguiste todos los pasos
3. Conserva el backup para restaurar si es necesario
4. Los archivos de log contienen información detallada para debugging

---

## ✅ Checklist Final

Antes de ejecutar, confirma:

- [ ] Backup manual realizado
- [ ] Aplicación MovieFlix cerrada
- [ ] Credenciales de base de datos verificadas
- [ ] Scripts descargados en `/scripts/`
- [ ] Conexión a base de datos confirmada

¡El script está diseñado para ser completamente seguro! 🛡️
