#!/bin/bash

# 🧹 MovieFlix - Script de Limpieza de Perfiles
# Elimina perfiles de prueba no deseados del servidor de producción

echo "🧹 =============================================="
echo "🎬 MovieFlix - Limpieza de Perfiles"
echo "🗑️  Eliminando perfiles: 'Prueba' y 'TestSinPin'"
echo "=============================================="

# Variables
PROJECT_PATH="/var/www/MovieFlix"
BACKUP_PATH="/var/www/MovieFlix/backup"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar ubicación
if [[ ! -d "$PROJECT_PATH" ]]; then
    error "No se encontró el directorio del proyecto en $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"
log "📍 Ubicación: $(pwd)"

# 1. Crear backup antes de la limpieza
log "💾 Creando backup de seguridad..."

mkdir -p "$BACKUP_PATH"

# Backup de perfiles
mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -e "SELECT * FROM profiles;" > "$BACKUP_PATH/profiles_backup_$TIMESTAMP.sql"

# Backup de contenido asociado
mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -e "SELECT * FROM content WHERE profile_id IN (
        SELECT id FROM profiles WHERE name IN ('Prueba', 'TestSinPin')
    );" > "$BACKUP_PATH/content_cleanup_backup_$TIMESTAMP.sql"

if [[ $? -eq 0 ]]; then
    log "✅ Backup creado exitosamente"
    info "📁 Ubicación: $BACKUP_PATH/"
else
    error "❌ Error creando backup"
    exit 1
fi

# 2. Mostrar perfiles que se van a eliminar
log "🔍 Identificando perfiles a eliminar..."

mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -e "SELECT id, name, emoji, created_at FROM profiles WHERE name IN ('Prueba', 'TestSinPin');"

PROFILES_TO_DELETE=$(mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -sN -e "SELECT COUNT(*) FROM profiles WHERE name IN ('Prueba', 'TestSinPin');")

if [[ $PROFILES_TO_DELETE -eq 0 ]]; then
    warning "No se encontraron perfiles para eliminar"
    info "Los perfiles 'Prueba' y 'TestSinPin' ya no existen"
    exit 0
fi

info "📊 Se eliminarán $PROFILES_TO_DELETE perfiles"

# 3. Mostrar contenido asociado
log "📋 Contenido asociado que se eliminará..."

mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -e "SELECT c.id, c.title, c.type, p.name as profile_name
        FROM content c
        JOIN profiles p ON c.profile_id = p.id
        WHERE p.name IN ('Prueba', 'TestSinPin');"

CONTENT_TO_DELETE=$(mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -sN -e "SELECT COUNT(*) FROM content WHERE profile_id IN (
        SELECT id FROM profiles WHERE name IN ('Prueba', 'TestSinPin')
    );")

info "📊 Se eliminarán $CONTENT_TO_DELETE elementos de contenido"

# 4. Confirmación del usuario
echo ""
warning "⚠️  ATENCIÓN: Esta acción es IRREVERSIBLE"
info "Se eliminarán $PROFILES_TO_DELETE perfiles y $CONTENT_TO_DELETE elementos de contenido"
info "Backup guardado en: $BACKUP_PATH/"
echo ""
read -p "¿Continuar con la eliminación? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warning "❌ Operación cancelada por el usuario"
    exit 0
fi

# 5. Ejecutar script de limpieza
log "🗑️  Ejecutando limpieza de perfiles..."

if [[ -f "scripts/remove-test-profiles.sql" ]]; then
    mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db < scripts/remove-test-profiles.sql

    if [[ $? -eq 0 ]]; then
        log "✅ Script SQL ejecutado exitosamente"
    else
        error "❌ Error ejecutando script SQL"
        exit 1
    fi
else
    error "❌ No se encontró el archivo scripts/remove-test-profiles.sql"
    exit 1
fi

# 6. Verificación final
log "🔍 Verificando resultado..."

REMAINING_PROFILES=$(mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -sN -e "SELECT COUNT(*) FROM profiles WHERE name IN ('Prueba', 'TestSinPin');")

REMAINING_CONTENT=$(mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -sN -e "SELECT COUNT(*) FROM content WHERE profile_id IN (
        SELECT id FROM profiles WHERE name IN ('Prueba', 'TestSinPin')
    );")

if [[ $REMAINING_PROFILES -eq 0 && $REMAINING_CONTENT -eq 0 ]]; then
    log "✅ Limpieza completada exitosamente"
    info "🗑️  Perfiles eliminados: $PROFILES_TO_DELETE"
    info "🗑️  Contenido eliminado: $CONTENT_TO_DELETE"
else
    error "❌ La limpieza no se completó correctamente"
    error "Perfiles restantes: $REMAINING_PROFILES"
    error "Contenido restante: $REMAINING_CONTENT"
fi

# 7. Mostrar perfiles restantes
log "📊 Perfiles restantes en el sistema:"

mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -e "SELECT id, name, emoji, created_at FROM profiles ORDER BY created_at ASC;"

# 8. Estadísticas finales
TOTAL_PROFILES=$(mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -sN -e "SELECT COUNT(*) FROM profiles;")

TOTAL_CONTENT=$(mysql -u movieflix_user -pmovieflix_secure_2025! movieflix_db \
    -sN -e "SELECT COUNT(*) FROM content;")

echo ""
echo "📊 ESTADÍSTICAS FINALES:"
info "👥 Total perfiles: $TOTAL_PROFILES"
info "🎬 Total contenido: $TOTAL_CONTENT"
info "💾 Backup: $BACKUP_PATH/profiles_backup_$TIMESTAMP.sql"
echo ""

log "🎉 Limpieza de perfiles completada exitosamente"
echo ""

# 9. Reiniciar PM2 para reflejar cambios
log "🔄 Reiniciando aplicación..."

pm2 restart movieflix-backend

if [[ $? -eq 0 ]]; then
    log "✅ Aplicación reiniciada correctamente"
else
    warning "⚠️ Error reiniciando aplicación"
fi

echo ""
log "🎬 MovieFlix listo con perfiles limpiados"
info "🌐 Verificar en: https://home-movieflix.duckdns.org"
