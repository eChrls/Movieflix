#!/bin/bash
# Script seguro para corrección de URLs pósters MovieFlix
# Incluye backup automático, validaciones y rollback

set -e  # Salir si cualquier comando falla

echo "🔧 MovieFlix - Corrección Segura URLs Pósters TMDb"
echo "=================================================="
echo ""

# Variables de configuración
BACKUP_DIR="/var/www/movieflix/backend/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/movieflix_before_poster_fix_$TIMESTAMP.sql"
APP_DIR="/var/www/movieflix/backend"

# Función para log con timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Función de cleanup en caso de error
cleanup() {
    log "❌ Error detectado. Limpiando..."
    if [ -f "$BACKUP_FILE" ]; then
        log "📄 Backup disponible en: $BACKUP_FILE"
        echo "Para restaurar ejecuta:"
        echo "mysql -h192.168.1.50 -umovieflix_user -p movieflix_db < $BACKUP_FILE"
    fi
    exit 1
}

# Configurar trap para errores
trap cleanup ERR

# Verificar que estamos en el directorio correcto
log "🔍 Verificando ubicación..."
cd "$APP_DIR" || {
    echo "❌ Error: No se puede acceder a $APP_DIR"
    exit 1
}

if [ ! -f "scripts/fix-poster-urls.js" ]; then
    echo "❌ Error: Script fix-poster-urls.js no encontrado"
    exit 1
fi

# Verificar conexión a base de datos
log "🔌 Verificando conexión a base de datos..."
if ! timeout 10 mysql -h192.168.1.50 -umovieflix_user -p"movieflix_secure_2025!" movieflix_db -e "SELECT 1;" >/dev/null 2>&1; then
    echo "❌ Error: No se puede conectar a la base de datos"
    exit 1
fi

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DIR"

# Realizar backup automático
log "💾 Creando backup automático..."
mysqldump -h192.168.1.50 -umovieflix_user -p"movieflix_secure_2025!" movieflix_db content > "$BACKUP_FILE"

if [ ! -f "$BACKUP_FILE" ] || [ ! -s "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup falló"
    exit 1
fi

log "✅ Backup creado: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"

# Sincronizar código desde GitHub
log "🔄 Sincronizando código desde GitHub..."
git pull origin main

# Verificar que hay contenido para corregir
log "🔍 Analizando contenido a corregir..."
INCORRECT_URLS=$(mysql -h192.168.1.50 -umovieflix_user -p"movieflix_secure_2025!" movieflix_db -se "
    SELECT COUNT(*) FROM content
    WHERE poster_path LIKE '%image.tmdb.org/t/medium%'
       OR poster_path LIKE '%image.tmdb.org/t/original%'
       OR backdrop_path LIKE '%image.tmdb.org/t/medium%'
       OR backdrop_path LIKE '%image.tmdb.org/t/original%'
")

if [ "$INCORRECT_URLS" -eq 0 ]; then
    log "🎉 No hay URLs que corregir. Sistema ya actualizado."
else
    log "📊 URLs para corregir: $INCORRECT_URLS elementos"

    # Ejecutar corrección
    log "🚀 Ejecutando corrección de URLs..."
    node scripts/fix-poster-urls.js

    # Verificar que la corrección fue exitosa
    REMAINING_INCORRECT=$(mysql -h192.168.1.50 -umovieflix_user -p"movieflix_secure_2025!" movieflix_db -se "
        SELECT COUNT(*) FROM content
        WHERE poster_path LIKE '%image.tmdb.org/t/medium%'
           OR poster_path LIKE '%image.tmdb.org/t/original%'
           OR backdrop_path LIKE '%image.tmdb.org/t/medium%'
           OR backdrop_path LIKE '%image.tmdb.org/t/original%'
    ")

    if [ "$REMAINING_INCORRECT" -eq 0 ]; then
        log "✅ Corrección exitosa: $INCORRECT_URLS URLs corregidas"
    else
        log "⚠️ Advertencia: Quedan $REMAINING_INCORRECT URLs sin corregir"
    fi
fi

# Reiniciar aplicación
log "🔄 Reiniciando aplicación..."
pm2 restart movieflix-backend

# Verificar que la aplicación está corriendo
sleep 3
if pm2 describe movieflix-backend | grep -q "online"; then
    log "✅ Aplicación reiniciada correctamente"
else
    log "❌ Error al reiniciar aplicación"
    exit 1
fi

# Verificar estado final
log "📊 Verificación final del sistema..."
pm2 status

echo ""
echo "🎉 ¡CORRECCIÓN COMPLETADA EXITOSAMENTE!"
echo "================================================"
echo "✅ Backup seguro creado: $BACKUP_FILE"
echo "✅ URLs de pósters corregidas"
echo "✅ Aplicación reiniciada y funcionando"
echo ""
echo "🌐 Verificar en: https://home-movieflix.duckdns.org"
echo "💡 Presiona Ctrl+F5 en el navegador para limpiar caché"
echo ""
echo "📁 Para futuras restauraciones:"
echo "   mysql -h192.168.1.50 -umovieflix_user -p movieflix_db < $BACKUP_FILE"
