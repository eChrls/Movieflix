#!/bin/bash
# Script para corregir URLs de pósters TMDb en servidor Orange Pi

echo "🔧 MovieFlix - Corrección URLs Pósters TMDb"
echo "=========================================="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "scripts/fix-poster-urls.js" ]; then
    echo "❌ Error: Ejecuta este script desde el directorio backend de MovieFlix"
    echo "Ubicación correcta: /var/www/movieflix/backend/"
    exit 1
fi

echo "🔍 Paso 1: Verificando URLs actuales..."
echo ""

# Ejecutar script de corrección
node scripts/fix-poster-urls.js

echo ""
echo "✅ Corrección completada!"
echo ""
echo "🔄 Paso 2: Reiniciando aplicación..."
pm2 restart movieflix-backend

echo ""
echo "🎯 Paso 3: Verificación manual:"
echo "1. Abre https://home-movieflix.duckdns.org"
echo "2. Presiona Ctrl+F5 para limpiar caché del navegador"
echo "3. Verifica que las portadas ahora cargan correctamente"
echo ""
echo "🎉 ¡Proceso completado!"
