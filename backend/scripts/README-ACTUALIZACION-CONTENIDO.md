# 🔄 MovieFlix - Actualizador de Contenido Existente

## 📋 Descripción del Problema

El contenido existente en MovieFlix fue insertado manualmente sin datos completos de las APIs TMDb y OMDb. Esto resulta en:

- ❌ **Tarjetas sin pósters**: No se muestran las imágenes
- ❌ **Sin ratings**: No aparecen las puntuaciones IMDB/TMDb
- ❌ **Enlaces rotos**: Faltan IDs de IMDB para enlaces externos
- ❌ **Información incompleta**: Sin resúmenes, duración, etc.

## 🎯 Solución Implementada

Se han creado scripts automatizados que:

1. **Analizan** el contenido existente para identificar datos faltantes
2. **Buscan** información completa en TMDb y OMDb usando título + año
3. **Actualizan** automáticamente la base de datos con datos completos
4. **Preservan** la integridad de datos con backups automáticos

## 📁 Scripts Creados

### 1. `analyze-incomplete-content.js`

**Propósito**: Analizar qué contenido necesita actualización

```bash
node scripts/analyze-incomplete-content.js
```

**Funcionalidad**:

- Escanea la base de datos buscando contenido incompleto
- Muestra estadísticas detalladas de datos faltantes
- Lista los primeros 10 elementos que necesitan actualización

### 2. `update-incomplete-content.js`

**Propósito**: Actualización masiva de todo el contenido incompleto

```bash
node scripts/update-incomplete-content.js
```

**Funcionalidades**:

- ✅ Busca en **TMDb API** por título + año + tipo (película/serie)
- ✅ Obtiene **pósters, fondos, resúmenes, duración, géneros**
- ✅ Busca en **OMDb API** para ratings precisos de IMDB
- ✅ Actualiza **tmdb_id, imdb_id, rating, poster_path, overview**
- ✅ Respeta límites de APIs con pausas entre llamadas
- ✅ Manejo robusto de errores y timeouts

### 3. `update-single-content.js`

**Propósito**: Actualizar elementos individuales para pruebas

```bash
node scripts/update-single-content.js <ID>
```

**Uso**:

```bash
# Ver lista de contenido incompleto
node scripts/update-single-content.js

# Actualizar elemento específico (ej: ID 15)
node scripts/update-single-content.js 15
```

### 4. `safe-update-content.bat` (Windows)

**Propósito**: Script seguro con backup automático

```cmd
safe-update-content.bat
```

**Funcionalidades**:

- 🛡️ **Backup automático** antes de cualquier cambio
- 🔍 **Análisis previo** para mostrar qué se va a actualizar
- ✋ **Confirmación del usuario** antes de proceder
- 📊 **Resumen final** con estadísticas de actualización
- 🔄 **Instrucciones de rollback** en caso de problemas

### 5. `safe-update-content.sh` (Linux/Mac)

**Propósito**: Versión Unix del script seguro

```bash
chmod +x scripts/safe-update-content.sh
./scripts/safe-update-content.sh
```

## 🚀 Instrucciones de Uso

### Método Recomendado (Seguro)

**Para Windows:**

```cmd
cd backend
safe-update-content.bat
```

**Para Linux/Mac:**

```bash
cd backend
chmod +x scripts/safe-update-content.sh
./scripts/safe-update-content.sh
```

### Método Manual (Paso a Paso)

1. **Análisis inicial**:

   ```bash
   cd backend
   node scripts/analyze-incomplete-content.js
   ```

2. **Backup manual** (opcional pero recomendado):

   ```bash
   mysqldump -h192.168.1.50 -umovieflix_user -p movieflix_db content > backup_content.sql
   ```

3. **Prueba con un elemento**:

   ```bash
   node scripts/update-single-content.js 15
   ```

4. **Actualización completa**:
   ```bash
   node scripts/update-incomplete-content.js
   ```

## 🔧 Configuración Requerida

### Variables de Entorno (.env)

```properties
# APIs necesarias para actualización
TMDB_API_KEY=a2e351c494039319d6d537923a7d972a
OMDB_API_KEY=ee43f6ac

# Base de datos
DB_HOST=192.168.1.50
DB_USER=movieflix_user
DB_PASSWORD=movieflix_secure_2025!
DB_NAME=movieflix_db
```

### Dependencias Node.js

```bash
npm install mysql2 axios dotenv
```

## 📊 Proceso de Actualización

### 1. Búsqueda en TMDb

```javascript
// Busca por título + año + tipo
GET https://api.themoviedb.org/3/search/movie?query=titulo&year=2020
GET https://api.themoviedb.org/3/search/tv?query=titulo&first_air_date_year=2020

// Obtiene detalles completos
GET https://api.themoviedb.org/3/movie/{id}?append_to_response=external_ids
```

**Datos obtenidos**:

- `tmdb_id`: ID interno de TMDb
- `poster_path`: URL del póster
- `backdrop_path`: URL del fondo
- `overview`: Resumen en español
- `runtime`: Duración en minutos
- `genres`: Array de géneros
- `imdb_id`: ID de IMDB (desde external_ids)

### 2. Búsqueda en OMDb

```javascript
// Busca rating preciso por IMDB ID
GET http://www.omdbapi.com/?i=tt1234567&apikey=KEY

// Fallback por título + año
GET http://www.omdbapi.com/?t=titulo&y=2020&apikey=KEY
```

**Datos obtenidos**:

- `imdb_rating`: Puntuación IMDB (más precisa que TMDb)
- `runtime`: Duración (verificación cruzada)

### 3. Actualización en Base de Datos

```sql
UPDATE content SET
  title_en = ?,
  overview = ?,
  poster_path = ?,
  backdrop_path = ?,
  runtime = ?,
  imdb_id = ?,
  tmdb_id = ?,
  rating = ?,
  genres = ?,
  updated_at = CURRENT_TIMESTAMP
WHERE id = ?
```

## 🛡️ Medidas de Seguridad

### Backup Automático

- Se crea antes de cualquier modificación
- Formato: `movieflix_before_content_update_YYYYMMDD_HHMMSS.sql`
- Ubicación: `backend/backup/`

### Restauración en Caso de Problemas

```bash
mysql -h192.168.1.50 -umovieflix_user -p movieflix_db < backup/backup_file.sql
```

### Manejo de Errores

- ✅ **Timeouts**: 10 segundos máximo por llamada API
- ✅ **Rate limiting**: Pausa de 1 segundo entre llamadas
- ✅ **Transacciones**: Cada actualización es atómica
- ✅ **Validación**: Verificación de datos antes de insertar
- ✅ **Logs detallados**: Para debugging y seguimiento

## 📈 Resultados Esperados

Después de ejecutar la actualización:

### ✅ En la Base de Datos

- Todos los campos `poster_path` tendrán URLs válidas
- Los `rating` tendrán valores precisos de IMDB/TMDb
- Los `imdb_id` permitirán enlaces externos
- Los `overview` tendrán resúmenes completos
- Los `tmdb_id` habilitarán futuras integraciones

### ✅ En la Interfaz Web

- 🖼️ **Pósters visibles**: Todas las tarjetas mostrarán imágenes
- ⭐ **Ratings mostrados**: Puntuaciones IMDB en las tarjetas
- 🔗 **Enlaces funcionales**: Botones "Ver en IMDB" operativos
- 📝 **Información completa**: Resúmenes y detalles disponibles
- 🏷️ **Géneros actualizados**: Clasificación mejorada

## 🔄 Sincronización con Servidor

Después de la actualización local:

1. **Commit cambios**:

   ```bash
   git add .
   git commit -m "Actualización automática de contenido con APIs TMDb/OMDb"
   git push origin main
   ```

2. **Actualizar servidor Orange Pi**:

   ```bash
   # En el servidor
   cd /var/www/movieflix
   git pull origin main
   pm2 restart movieflix-backend
   ```

3. **Sincronizar base de datos** (si es necesario):

   ```bash
   # Exportar desde local
   mysqldump movieflix_db > movieflix_updated.sql

   # Importar en servidor
   mysql -u movieflix_user -p movieflix_db < movieflix_updated.sql
   ```

## 🎯 Casos de Uso

### Escenario 1: Primera Ejecución

```bash
# Analizar primero
node scripts/analyze-incomplete-content.js

# Probar con un elemento
node scripts/update-single-content.js 5

# Si funciona bien, actualizar todo
./scripts/safe-update-content.bat
```

### Escenario 2: Contenido Nuevo Agregado Manualmente

```bash
# Encontrar nuevos elementos sin datos
node scripts/analyze-incomplete-content.js

# Actualizar solo los nuevos
node scripts/update-incomplete-content.js
```

### Escenario 3: Corrección de Elemento Específico

```bash
# Ver lista de IDs
node scripts/update-single-content.js

# Actualizar elemento específico
node scripts/update-single-content.js 25
```

## 🔍 Troubleshooting

### Error: API Key no configurada

```bash
# Verificar .env
grep "TMDB_API_KEY\|OMDB_API_KEY" .env

# Debe mostrar:
TMDB_API_KEY=a2e351c494039319d6d537923a7d972a
OMDB_API_KEY=ee43f6ac
```

### Error: Conexión a base de datos

```bash
# Verificar conexión
mysql -h192.168.1.50 -umovieflix_user -p movieflix_db -e "SELECT COUNT(*) FROM content;"
```

### Error: Elemento no encontrado en APIs

- Normal para contenido muy antiguo o regional
- El script lo omitirá y continuará con el siguiente
- Se puede actualizar manualmente si es necesario

### Restaurar Backup

```bash
# Listar backups disponibles
ls -la backup/

# Restaurar backup específico
mysql -h192.168.1.50 -umovieflix_user -p movieflix_db < backup/movieflix_before_content_update_20250910_143021.sql
```

## 🎉 Conclusión

Con estos scripts, el contenido existente en MovieFlix se transformará de tarjetas básicas con solo título y año, a tarjetas completas con pósters, ratings, resúmenes y enlaces funcionales, manteniendo la integridad de datos y permitiendo rollback en caso de problemas.

---

**Autor**: GitHub Copilot
**Fecha**: 10 de septiembre de 2025
**Proyecto**: MovieFlix Content Management System
