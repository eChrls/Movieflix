#!/bin/bash

# Script de actualización segura de contenido MovieFlix
# Incluye backup automático y verificaciones

echo "🔧 MovieFlix - Actualizador de Contenido Seguro"
echo "=============================================="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ] || [ ! -d "scripts" ]; then
    echo "❌ Error: Ejecuta este script desde el directorio backend de MovieFlix"
    exit 1
fi

# Verificar que el archivo .env existe
if [ ! -f ".env" ]; then
    echo "❌ Error: Archivo .env no encontrado"
    echo "   Asegúrate de tener configuradas las API keys de TMDb y OMDb"
    exit 1
fi

# Crear directorio de backup si no existe
mkdir -p backup

# Crear backup antes de actualizar
BACKUP_DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup/movieflix_before_content_update_${BACKUP_DATE}.sql"

echo "📦 Creando backup de seguridad..."

# Verificar credenciales de la base de datos desde .env
DB_HOST=$(grep DB_HOST .env | cut -d '=' -f2)
DB_USER=$(grep DB_USER .env | cut -d '=' -f2)
DB_PASSWORD=$(grep DB_PASSWORD .env | cut -d '=' -f2)
DB_NAME=$(grep DB_NAME .env | cut -d '=' -f2)

# Crear backup usando mysqldump
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" content > "$BACKUP_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✅ Backup creado: $BACKUP_FILE ($BACKUP_SIZE)"
else
    echo "⚠️  Warning: No se pudo crear backup automático"
    echo "   Continúa bajo tu responsabilidad"
    read -p "   ¿Deseas continuar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operación cancelada"
        exit 1
    fi
fi

echo ""

# Ejecutar análisis previo
echo "🔍 Analizando contenido incompleto..."
node scripts/analyze-incomplete-content.js

echo ""
read -p "¿Deseas continuar con la actualización? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Actualización cancelada"
    exit 0
fi

echo ""
echo "🚀 Iniciando actualización de contenido..."
echo "   Esto puede tomar varios minutos dependiendo de la cantidad de contenido"
echo ""

# Ejecutar actualización
node scripts/update-incomplete-content.js

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 ¡Actualización completada exitosamente!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "   1. Verifica la aplicación web en el navegador"
    echo "   2. Comprueba que los pósters y ratings se muestran correctamente"
    echo "   3. Si hay problemas, restaura desde: $BACKUP_FILE"
    echo ""
    echo "🔄 Para restaurar el backup en caso de problemas:"
    echo "   mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME < $BACKUP_FILE"
else
    echo ""
    echo "❌ Error durante la actualización"
    echo "🔄 Para restaurar el backup:"
    echo "   mysql -h$DB_HOST -u$DB_USER -p$DB_PASSWORD $DB_NAME < $BACKUP_FILE"
    exit 1
fi
