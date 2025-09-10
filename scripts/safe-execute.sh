#!/bin/bash

# ========================================
# MOVIEFLIX - SCRIPT DE BACKUP Y EJECUCIÓN SEGURA
# ========================================
# Este script realiza un backup antes de ejecutar cambios
# y proporciona rollback automático en caso de error

# Configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/movieflix_backup_$DATE.sql"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para verificar dependencias
check_dependencies() {
    log "Verificando dependencias..."

    # Verificar mysql/mysqldump
    if ! command -v mysqldump &> /dev/null; then
        error "mysqldump no está instalado"
        exit 1
    fi

    if ! command -v mysql &> /dev/null; then
        error "mysql client no está instalado"
        exit 1
    fi

    success "Dependencias verificadas"
}

# Función para cargar variables de entorno
load_env() {
    log "Cargando configuración..."

    if [ -f "$PROJECT_DIR/.env" ]; then
        export $(grep -v '^#' "$PROJECT_DIR/.env" | xargs)
        success "Variables de entorno cargadas desde .env"
    else
        warning "Archivo .env no encontrado, usando valores por defecto"
        export DB_HOST=${DB_HOST:-localhost}
        export DB_NAME=${DB_NAME:-movieflix_db}
        export DB_USER=${DB_USER:-movieflix_user}
        export DB_PASSWORD=${DB_PASSWORD:-movieflix_password_2025}
    fi

    log "Configuración: Host=$DB_HOST, DB=$DB_NAME, User=$DB_USER"
}

# Función para verificar conexión a la base de datos
test_connection() {
    log "Verificando conexión a la base de datos..."

    if mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME; SELECT 1;" &> /dev/null; then
        success "Conexión a la base de datos exitosa"
    else
        error "No se puede conectar a la base de datos"
        error "Verifica las credenciales y que el servidor MySQL esté ejecutándose"
        exit 1
    fi
}

# Función para crear directorio de backup
setup_backup_dir() {
    log "Configurando directorio de backup..."

    mkdir -p "$BACKUP_DIR"

    if [ $? -eq 0 ]; then
        success "Directorio de backup preparado: $BACKUP_DIR"
    else
        error "No se pudo crear el directorio de backup"
        exit 1
    fi
}

# Función para realizar backup
create_backup() {
    log "Creando backup de la base de datos..."

    mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        --single-transaction \
        --routines \
        --triggers \
        --lock-tables=false \
        "$DB_NAME" > "$BACKUP_FILE"

    if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
        success "Backup creado exitosamente: $BACKUP_FILE"

        # Mostrar tamaño del backup
        local size=$(du -h "$BACKUP_FILE" | cut -f1)
        log "Tamaño del backup: $size"

        return 0
    else
        error "Fallo al crear el backup"
        rm -f "$BACKUP_FILE"
        exit 1
    fi
}

# Función para verificar el estado actual de la base de datos
verify_db_state() {
    log "Verificando estado actual de la base de datos..."

    local content_count=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        -D"$DB_NAME" -se "SELECT COUNT(*) FROM content;")

    local platform_count=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        -D"$DB_NAME" -se "SELECT COUNT(*) FROM platforms;")

    log "Estado actual:"
    log "  - Contenido total: $content_count registros"
    log "  - Plataformas: $platform_count registros"

    # Guardar estado para comparación posterior
    echo "$content_count" > "/tmp/movieflix_content_before"
    echo "$platform_count" > "/tmp/movieflix_platforms_before"
}

# Función para ejecutar el script SQL
execute_sql_script() {
    log "Ejecutando script de inserción de contenido..."

    local sql_file="$SCRIPT_DIR/add-missing-content-safe.sql"

    if [ ! -f "$sql_file" ]; then
        error "Script SQL no encontrado: $sql_file"
        exit 1
    fi

    # Ejecutar script SQL con logging
    mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        -D"$DB_NAME" \
        -v < "$sql_file" 2>&1 | tee "/tmp/movieflix_execution_log.txt"

    local exit_code=${PIPESTATUS[0]}

    if [ $exit_code -eq 0 ]; then
        success "Script SQL ejecutado exitosamente"
        return 0
    else
        error "Error al ejecutar el script SQL (código: $exit_code)"
        return 1
    fi
}

# Función para verificar resultados
verify_results() {
    log "Verificando resultados..."

    local content_after=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        -D"$DB_NAME" -se "SELECT COUNT(*) FROM content;")

    local content_before=$(cat "/tmp/movieflix_content_before")
    local new_content=$((content_after - content_before))

    log "Resultados:"
    log "  - Contenido antes: $content_before"
    log "  - Contenido después: $content_after"
    log "  - Nuevo contenido agregado: $new_content"

    if [ $new_content -gt 0 ]; then
        success "$new_content nuevos elementos agregados exitosamente"
    else
        warning "No se agregó contenido nuevo (posiblemente ya existía)"
    fi

    # Verificar integridad
    local integrity_check=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        -D"$DB_NAME" -se "SELECT COUNT(*) FROM content WHERE profile_id IS NULL;")

    if [ "$integrity_check" -eq 0 ]; then
        success "Verificación de integridad: OK"
    else
        error "Verificación de integridad: FALLO ($integrity_check registros sin perfil)"
        return 1
    fi
}

# Función para restaurar backup en caso de error
restore_backup() {
    warning "Iniciando restauración desde backup..."

    mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        "$DB_NAME" < "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        success "Base de datos restaurada desde backup"
    else
        error "CRÍTICO: Fallo al restaurar backup"
        error "Backup disponible en: $BACKUP_FILE"
    fi
}

# Función para limpiar archivos temporales
cleanup() {
    log "Limpiando archivos temporales..."
    rm -f "/tmp/movieflix_content_before"
    rm -f "/tmp/movieflix_platforms_before"
}

# Función principal
main() {
    echo "========================================="
    echo "MovieFlix - Script de Inserción Segura"
    echo "========================================="
    echo ""

    # Verificaciones iniciales
    check_dependencies
    load_env
    test_connection
    setup_backup_dir

    # Estado inicial
    verify_db_state

    # Crear backup
    create_backup

    # Ejecutar script
    if execute_sql_script; then
        # Verificar resultados
        if verify_results; then
            success "✅ Proceso completado exitosamente"
            log "Backup disponible en: $BACKUP_FILE"
        else
            error "❌ Verificación de resultados falló"
            restore_backup
            exit 1
        fi
    else
        error "❌ Ejecución del script falló"
        restore_backup
        exit 1
    fi

    # Limpieza
    cleanup

    echo ""
    echo "========================================="
    echo "✅ Proceso finalizado exitosamente"
    echo "========================================="
    echo ""
    echo "📝 Próximos pasos:"
    echo "  1. Reiniciar el servidor MovieFlix si está ejecutándose"
    echo "  2. Verificar que el nuevo contenido aparece en la aplicación"
    echo "  3. El backup está disponible en: $BACKUP_FILE"
    echo ""
}

# Verificar argumentos
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "MovieFlix - Script de Inserción Segura de Contenido"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  --help, -h     Mostrar esta ayuda"
    echo "  --no-backup    Ejecutar sin crear backup (NO RECOMENDADO)"
    echo ""
    echo "Este script:"
    echo "  ✅ Crea un backup automático antes de los cambios"
    echo "  ✅ Verifica la conexión a la base de datos"
    echo "  ✅ Ejecuta el script SQL de forma segura"
    echo "  ✅ Verifica los resultados"
    echo "  ✅ Restaura automáticamente en caso de error"
    echo ""
    exit 0
fi

# Ejecutar función principal
main "$@"
