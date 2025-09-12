-- ===================================
-- SCRIPT PARA VERIFICAR ESTADO DE BD
-- MovieFlix - Fecha: 12 Sep 2025
-- ===================================

-- Verificar conexión y estado de la base de datos

USE movieflix_db;

-- 1. Verificar que la base de datos existe y está accesible
SELECT 'Base de datos movieflix_db conectada correctamente' as status;

-- 2. Mostrar estadísticas de contenido
SELECT 
    'Estadísticas de Contenido' as section,
    (SELECT COUNT(*) FROM content) as total_content,
    (SELECT COUNT(*) FROM content WHERE type = 'movie') as total_movies,
    (SELECT COUNT(*) FROM content WHERE type = 'series') as total_series;

-- 3. Verificar contenido con géneros válidos
SELECT 
    'Estado de Géneros' as section,
    COUNT(*) as total_with_genres
FROM content 
WHERE genres IS NOT NULL AND genres != '';

-- 4. Mostrar algunas películas de ejemplo para verificar datos
SELECT 
    'Contenido de Ejemplo (5 películas)' as section,
    id, title, type, year, rating
FROM content 
WHERE type = 'movie' 
ORDER BY rating DESC 
LIMIT 5;

-- 5. Verificar últimas actualizaciones
SELECT 
    'Última Actividad' as section,
    MAX(id) as ultimo_contenido_id,
    COUNT(*) as total_registros
FROM content;

-- 6. Estado de conexión final
SELECT 
    'Conexión MySQL' as section,
    CONNECTION_ID() as connection_id,
    DATABASE() as current_database,
    USER() as current_user;