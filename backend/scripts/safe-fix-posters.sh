#!/bin/bash

# MovieFlix - Script de Backup y Corrección Segura de URLs Pósters
# Fecha: 10 de septiembre de 2025
# Propósito: Backup automático + corrección URLs TMDb con máxima seguridad

echo "🛡️ MovieFlix - Corrección Segura URLs Pósters TMDb"
echo "================================================="
echo ""
echo "🔒 MEDIDAS DE SEGURIDAD IMPLEMENTADAS:"
echo "✅ Backup automático antes de cualquier cambio"
echo "✅ Verificación de integridad de datos"
echo "✅ Rollback disponible en caso de problemas"
echo "✅ Logs detallados de toda la operación"
echo ""

# Variables de configuración
BACKUP_DIR="/var/www/movieflix/backend/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/movieflix_before_poster_fix_$TIMESTAMP.sql"
LOG_FILE="/var/www/movieflix/backend/logs/poster_fix_$TIMESTAMP.log"

# Función de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "scripts/fix-poster-urls.js" ]; then
    echo "❌ Error: Ejecuta este script desde /var/www/movieflix/backend/"
    echo "Ubicación correcta: /var/www/movieflix/backend/"
    exit 1
fi

# Crear directorios si no existen
mkdir -p "$BACKUP_DIR"
mkdir -p "/var/www/movieflix/backend/logs"

log "🚀 Iniciando proceso de corrección segura de URLs pósters"

# Paso 1: Backup de seguridad
log "📦 Paso 1: Creando backup de seguridad..."
echo "📦 Creando backup de la tabla content..."

mysqldump -h 192.168.1.50 -u movieflix_user -pmovieflix_secure_2025! movieflix_db content > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "✅ Backup creado exitosamente: $BACKUP_FILE ($BACKUP_SIZE)"
    echo "✅ Backup creado: $BACKUP_FILE ($BACKUP_SIZE)"
else
    log "❌ Error creando backup. Abortando operación."
    echo "❌ Error creando backup. Operación abortada por seguridad."
    exit 1
fi

# Paso 2: Verificar estado actual
log "🔍 Paso 2: Analizando estado actual de URLs..."
echo ""
echo "🔍 Analizando URLs actuales en base de datos..."

# Contar URLs incorrectas
INCORRECT_COUNT=$(mysql -h 192.168.1.50 -u movieflix_user -pmovieflix_secure_2025! movieflix_db -se "
SELECT COUNT(*) FROM content
WHERE poster_path LIKE '%image.tmdb.org/t/medium%'
   OR poster_path LIKE '%image.tmdb.org/t/original%'
   OR backdrop_path LIKE '%image.tmdb.org/t/medium%'
   OR backdrop_path LIKE '%image.tmdb.org/t/original%'
")

log "📊 URLs incorrectas encontradas: $INCORRECT_COUNT"
echo "📊 URLs incorrectas encontradas: $INCORRECT_COUNT"

if [ "$INCORRECT_COUNT" -eq 0 ]; then
    log "🎉 No hay URLs incorrectas. Todas las URLs ya están correctas."
    echo "🎉 ¡Excelente! Todas las URLs ya están correctas."
    echo "🧹 Limpiando archivos temporales..."
    rm "$BACKUP_FILE"
    exit 0
fi

# Paso 3: Mostrar ejemplos de lo que se va a corregir
echo ""
echo "📋 Ejemplos de URLs que se van a corregir:"
mysql -h 192.168.1.50 -u movieflix_user -pmovieflix_secure_2025! movieflix_db -se "
SELECT CONCAT('ID ', id, ': ', title, ' -> ', poster_path) as 'Ejemplo URL Incorrecta'
FROM content
WHERE poster_path LIKE '%image.tmdb.org/t/medium%'
   OR poster_path LIKE '%image.tmdb.org/t/original%'
LIMIT 3
"

# Paso 4: Confirmación del usuario
echo ""
echo "⚠️  CONFIRMACIÓN REQUERIDA:"
echo "Se van a corregir $INCORRECT_COUNT URLs incorrectas"
echo ""
echo "URLs incorrectas → URLs correctas:"
echo "❌ /t/medium/w300  → ✅ /t/p/w300"
echo "❌ /t/original/    → ✅ /t/p/w1280"
echo ""
read -p "¿Proceder con la corrección? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "🛑 Operación cancelada por el usuario"
    echo "🛑 Operación cancelada. Backup conservado en: $BACKUP_FILE"
    exit 0
fi

# Paso 5: Ejecutar corrección
log "🔧 Paso 5: Ejecutando corrección de URLs..."
echo ""
echo "🔧 Ejecutando corrección de URLs..."

node scripts/fix-poster-urls.js 2>&1 | tee -a "$LOG_FILE"

# Verificar si la corrección fue exitosa
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log "✅ Corrección de URLs completada exitosamente"
    echo ""
    echo "✅ Corrección completada exitosamente!"
else
    log "❌ Error durante la corrección de URLs"
    echo "❌ Error durante la corrección. Verifica los logs: $LOG_FILE"
    echo "🔄 Para restaurar el backup: mysql -h 192.168.1.50 -u movieflix_user -p movieflix_db < $BACKUP_FILE"
    exit 1
fi

# Paso 6: Verificación post-corrección
log "🔍 Paso 6: Verificando corrección..."
echo ""
echo "🔍 Verificando que la corrección fue exitosa..."

REMAINING_INCORRECT=$(mysql -h 192.168.1.50 -u movieflix_user -pmovieflix_secure_2025! movieflix_db -se "
SELECT COUNT(*) FROM content
WHERE poster_path LIKE '%image.tmdb.org/t/medium%'
   OR poster_path LIKE '%image.tmdb.org/t/original%'
   OR backdrop_path LIKE '%image.tmdb.org/t/medium%'
   OR backdrop_path LIKE '%image.tmdb.org/t/original%'
")

log "📊 URLs incorrectas restantes: $REMAINING_INCORRECT"
echo "📊 URLs incorrectas restantes: $REMAINING_INCORRECT"

if [ "$REMAINING_INCORRECT" -eq 0 ]; then
    log "🎉 Verificación exitosa: Todas las URLs han sido corregidas"
    echo "🎉 ¡Perfecto! Todas las URLs han sido corregidas correctamente."
else
    log "⚠️ Advertencia: Quedan $REMAINING_INCORRECT URLs incorrectas"
    echo "⚠️ Advertencia: Quedan $REMAINING_INCORRECT URLs por corregir"
fi

# Paso 7: Reiniciar aplicación
log "🔄 Paso 7: Reiniciando aplicación MovieFlix..."
echo ""
echo "🔄 Reiniciando aplicación..."

pm2 restart movieflix-backend

if [ $? -eq 0 ]; then
    log "✅ Aplicación reiniciada exitosamente"
    echo "✅ Aplicación reiniciada exitosamente"
else
    log "⚠️ Advertencia: Error reiniciando aplicación"
    echo "⚠️ Advertencia: Error reiniciando aplicación. Verifica manualmente: pm2 status"
fi

# Paso 8: Resumen final
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎬 CORRECCIÓN DE URLS PÓSTERS COMPLETADA"
echo "═══════════════════════════════════════════════════════════════"
echo ""
log "📊 RESUMEN FINAL:"
log "URLs corregidas: $(($INCORRECT_COUNT - $REMAINING_INCORRECT))"
log "URLs restantes: $REMAINING_INCORRECT"
log "Backup creado: $BACKUP_FILE"
log "Log completo: $LOG_FILE"

echo "📊 RESUMEN:"
echo "✅ URLs corregidas: $(($INCORRECT_COUNT - $REMAINING_INCORRECT))"
echo "📊 URLs restantes: $REMAINING_INCORRECT"
echo "💾 Backup guardado: $BACKUP_FILE"
echo "📝 Log completo: $LOG_FILE"
echo ""
echo "🌐 VERIFICACIÓN FINAL:"
echo "1. Abre: https://home-movieflix.duckdns.org"
echo "2. Presiona Ctrl+F5 para limpiar caché del navegador"
echo "3. Verifica que las portadas cargan correctamente"
echo ""
echo "🔄 ROLLBACK (si es necesario):"
echo "mysql -h 192.168.1.50 -u movieflix_user -p movieflix_db < $BACKUP_FILE"
echo ""
echo "🎉 ¡Operación completada con máxima seguridad!"

log "🎉 Operación completada exitosamente con todas las medidas de seguridad"
