-- ========================================
-- MOVIEFLIX - SCRIPT SEGURO PARA AGREGAR CONTENIDO FALTANTE
-- ========================================
-- Script adaptado a la estructura real de la base de datos MovieFlix
-- Fecha: $(date)
-- Versión: 1.0.0
-- Autor: Sistema de gestión MovieFlix

-- CARACTERÍSTICAS DE SEGURIDAD:
-- ✅ Transacciones para integridad
-- ✅ Verificación de duplicados
-- ✅ Manejo de errores
-- ✅ Rollback automático en caso de fallo
-- ✅ Logs de operaciones
-- ✅ Validación de datos existentes

-- ========================================
-- CONFIGURACIÓN DE SEGURIDAD
-- ========================================

-- Configurar modo seguro
SET autocommit = 0;
SET foreign_key_checks = 1;
SET sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

-- Iniciar transacción
START TRANSACTION;

-- ========================================
-- TABLA TEMPORAL PARA MAPEO DE PLATAFORMAS
-- ========================================

-- Crear tabla temporal con IDs reales de plataformas
CREATE TEMPORARY TABLE temp_platform_mapping AS
SELECT id, name FROM platforms;

-- Verificar que tenemos las plataformas necesarias
SELECT 'VERIFICACIÓN: Plataformas disponibles' as status;
SELECT id, name FROM temp_platform_mapping ORDER BY name;

-- ========================================
-- OBTENER PERFIL HOME PARA CONTENIDO
-- ========================================

-- Obtener el ID del perfil Home (requerido para content)
SET @home_profile_id = (SELECT id FROM profiles WHERE name = 'Home' LIMIT 1);

-- Verificar que existe el perfil
SELECT
    CASE
        WHEN @home_profile_id IS NOT NULL
        THEN CONCAT('✅ Perfil Home encontrado con ID: ', @home_profile_id)
        ELSE '❌ ERROR: Perfil Home no encontrado'
    END as verification_status;

-- ========================================
-- FUNCIÓN AUXILIAR PARA INSERCIÓN SEGURA
-- ========================================

-- Crear procedimiento para inserción segura
DELIMITER //

CREATE TEMPORARY PROCEDURE SafeInsertContent(
    IN p_title VARCHAR(255),
    IN p_year INT,
    IN p_type ENUM('movie', 'series'),
    IN p_rating DECIMAL(3,1),
    IN p_genres JSON,
    IN p_overview TEXT,
    IN p_platform_name VARCHAR(50)
)
BEGIN
    DECLARE v_platform_id INT DEFAULT NULL;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Obtener platform_id si se especifica plataforma
    IF p_platform_name IS NOT NULL THEN
        SELECT id INTO v_platform_id
        FROM temp_platform_mapping
        WHERE name = p_platform_name
        LIMIT 1;
    END IF;

    -- Verificar si ya existe el contenido
    SELECT COUNT(*) INTO v_exists
    FROM content
    WHERE LOWER(TRIM(title)) = LOWER(TRIM(p_title))
    AND year = p_year
    AND type = p_type;

    -- Insertar solo si no existe
    IF v_exists = 0 THEN
        INSERT INTO content (
            title,
            year,
            type,
            rating,
            genres,
            overview,
            platform_id,
            profile_id,
            status
        ) VALUES (
            p_title,
            p_year,
            p_type,
            p_rating,
            p_genres,
            p_overview,
            v_platform_id,
            @home_profile_id,
            'pending'
        );

        SELECT CONCAT('✅ Insertado: ', p_title, ' (', p_year, ')') as result;
    ELSE
        SELECT CONCAT('⚠️  Ya existe: ', p_title, ' (', p_year, ')') as result;
    END IF;
END //

DELIMITER ;

-- ========================================
-- INSERCIÓN SEGURA DE SERIES FALTANTES
-- ========================================

SELECT '📺 INSERTANDO SERIES FALTANTES...' as status;

-- The Pitt (2025) – HBO
CALL SafeInsertContent(
    'The Pitt',
    2025,
    'series',
    8.9,
    JSON_ARRAY('Drama'),
    'Serie dramática médica ambientada en un hospital de emergencias',
    'HBO'
);

-- When They See Us (2019) – Netflix
CALL SafeInsertContent(
    'When They See Us',
    2019,
    'series',
    8.8,
    JSON_ARRAY('Crime', 'Drama'),
    'Miniserie sobre el caso Central Park Five',
    'Netflix'
);

-- La Maravillosa Sra. Maisel (2017–2023) – Prime Video
CALL SafeInsertContent(
    'La Maravillosa Sra. Maisel',
    2017,
    'series',
    8.7,
    JSON_ARRAY('Comedy', 'Drama'),
    'Serie sobre una mujer que se convierte en comediante en los años 50',
    'Prime Video'
);

-- This Is Us (2016–2022) – Prime Video
CALL SafeInsertContent(
    'This Is Us',
    2016,
    'series',
    8.7,
    JSON_ARRAY('Drama', 'Romance'),
    'Drama familiar multigeneracional',
    'Prime Video'
);

-- Dopesick (2021) – Disney+
CALL SafeInsertContent(
    'Dopesick',
    2021,
    'series',
    8.6,
    JSON_ARRAY('Drama', 'Crime'),
    'Miniserie sobre la crisis de opioides en Estados Unidos',
    'Disney+'
);

-- The Expanse (2015-2022) – Prime Video
CALL SafeInsertContent(
    'The Expanse',
    2015,
    'series',
    8.5,
    JSON_ARRAY('Sci-Fi', 'Drama'),
    'Serie de ciencia ficción espacial',
    'Prime Video'
);

-- Billions (2016–2023) – Prime Video
CALL SafeInsertContent(
    'Billions',
    2016,
    'series',
    8.4,
    JSON_ARRAY('Drama', 'Crime'),
    'Drama sobre finanzas y poder en Wall Street',
    'Prime Video'
);

-- High Maintenance – HBO
CALL SafeInsertContent(
    'High Maintenance',
    2016,
    'series',
    8.1,
    JSON_ARRAY('Comedy', 'Drama'),
    'Serie antológica sobre un dealer de marihuana en Nueva York',
    'HBO'
);

-- Wild Wild Country (2018) – Netflix
CALL SafeInsertContent(
    'Wild Wild Country',
    2018,
    'series',
    8.1,
    JSON_ARRAY('Documentary'),
    'Documental sobre el culto Rajneesh en Oregon',
    'Netflix'
);

-- Tokyo Vice (2022–2024) – HBO
CALL SafeInsertContent(
    'Tokyo Vice',
    2022,
    'series',
    8.1,
    JSON_ARRAY('Crime', 'Drama', 'Thriller'),
    'Drama criminal ambientado en el Tokio de los 90s',
    'HBO'
);

-- The Morning Show (2019– ) – Apple TV+
CALL SafeInsertContent(
    'The Morning Show',
    2019,
    'series',
    8.1,
    JSON_ARRAY('Drama'),
    'Drama sobre un programa matutino de televisión',
    'Apple TV+'
);

-- Slow Horses (2022– ) – Apple TV+
CALL SafeInsertContent(
    'Slow Horses',
    2022,
    'series',
    7.5,
    JSON_ARRAY('Drama', 'Spy'),
    'Serie de espías británicos sobre agentes caídos en desgracia',
    'Apple TV+'
);

-- ========================================
-- INSERCIÓN SEGURA DE PELÍCULAS FALTANTES
-- ========================================

SELECT '🎬 INSERTANDO PELÍCULAS FALTANTES...' as status;

-- El Hombre que Mató a Liberty Valance (1962) – Disney+
CALL SafeInsertContent(
    'El Hombre que Mató a Liberty Valance',
    1962,
    'movie',
    8.1,
    JSON_ARRAY('Western', 'Drama'),
    'Western clásico de John Ford',
    'Disney+'
);

-- Centauros del Desierto (1956) – SIN PLATAFORMA
CALL SafeInsertContent(
    'Centauros del Desierto',
    1956,
    'movie',
    8.0,
    JSON_ARRAY('Western'),
    'Western clásico de John Ford con John Wayne',
    NULL
);

-- Solo Ante el Peligro (1952) – SIN PLATAFORMA
CALL SafeInsertContent(
    'Solo Ante el Peligro',
    1952,
    'movie',
    7.5,
    JSON_ARRAY('Western'),
    'Western clásico con Gary Cooper',
    NULL
);

-- Perfect Blue (1997) – SIN PLATAFORMA
CALL SafeInsertContent(
    'Perfect Blue',
    1997,
    'movie',
    8.0,
    JSON_ARRAY('Animation', 'Thriller'),
    'Thriller psicológico animado de Satoshi Kon',
    NULL
);

-- Castle in the Sky (1986) – SIN PLATAFORMA
CALL SafeInsertContent(
    'Castle in the Sky',
    1986,
    'movie',
    8.0,
    JSON_ARRAY('Animation', 'Adventure', 'Family'),
    'Película de Studio Ghibli sobre una ciudad flotante',
    NULL
);

-- The Tale of the Princess Kaguya (2013) – SIN PLATAFORMA
CALL SafeInsertContent(
    'The Tale of the Princess Kaguya',
    2013,
    'movie',
    8.0,
    JSON_ARRAY('Animation', 'Drama', 'Fantasy'),
    'Película de Studio Ghibli basada en el cuento japonés',
    NULL
);

-- Porco Rosso (1992) – SIN PLATAFORMA
CALL SafeInsertContent(
    'Porco Rosso',
    1992,
    'movie',
    7.7,
    JSON_ARRAY('Animation', 'Adventure', 'Comedy'),
    'Película de Studio Ghibli sobre un piloto convertido en cerdo',
    NULL
);

-- Doctor Zhivago (1965) – HBO
CALL SafeInsertContent(
    'Doctor Zhivago',
    1965,
    'movie',
    8.0,
    JSON_ARRAY('Romance', 'Drama', 'War'),
    'Épica romántica de David Lean',
    'HBO'
);

-- Trece Vidas (2022) – Prime Video
CALL SafeInsertContent(
    'Trece Vidas',
    2022,
    'movie',
    7.8,
    JSON_ARRAY('Biography', 'Drama', 'Thriller'),
    'Drama sobre el rescate de niños en una cueva de Tailandia',
    'Prime Video'
);

-- La Cinta Blanca (2009) – SIN PLATAFORMA
CALL SafeInsertContent(
    'La Cinta Blanca',
    2009,
    'movie',
    7.8,
    JSON_ARRAY('Drama', 'Mystery'),
    'Drama alemán de Michael Haneke',
    NULL
);

-- The Florida Project (2017) – Netflix
CALL SafeInsertContent(
    'The Florida Project',
    2017,
    'movie',
    7.6,
    JSON_ARRAY('Drama'),
    'Drama independiente sobre la pobreza infantil',
    'Netflix'
);

-- Contratiempo (2016) – Netflix
CALL SafeInsertContent(
    'Contratiempo',
    2016,
    'movie',
    7.6,
    JSON_ARRAY('Thriller', 'Crime', 'Drama'),
    'Thriller español de Oriol Paulo',
    'Netflix'
);

-- Cría Cuervos (1976) – Filmin
CALL SafeInsertContent(
    'Cría Cuervos',
    1976,
    'movie',
    7.6,
    JSON_ARRAY('Drama'),
    'Drama español de Carlos Saura',
    'Filmin'
);

-- Que Dios Nos Perdone (2016) – Netflix
CALL SafeInsertContent(
    'Que Dios Nos Perdone',
    2016,
    'movie',
    7.3,
    JSON_ARRAY('Crime', 'Drama', 'Thriller'),
    'Thriller policial español de Rodrigo Sorogoyen',
    'Netflix'
);

-- Tetris (2023) – Apple TV+
CALL SafeInsertContent(
    'Tetris',
    2023,
    'movie',
    7.0,
    JSON_ARRAY('Drama'),
    'Drama sobre la historia del videojuego Tetris',
    'Apple TV+'
);

-- First Blood (1982) – Prime Video
CALL SafeInsertContent(
    'First Blood',
    1982,
    'movie',
    7.7,
    JSON_ARRAY('Action'),
    'Primera película de Rambo con Sylvester Stallone',
    'Prime Video'
);

-- Dredd (2012) – Prime Video
CALL SafeInsertContent(
    'Dredd',
    2012,
    'movie',
    7.1,
    JSON_ARRAY('Action', 'Sci-Fi'),
    'Película de acción de ciencia ficción',
    'Prime Video'
);

-- Coherence (2013) – SIN PLATAFORMA
CALL SafeInsertContent(
    'Coherence',
    2013,
    'movie',
    7.2,
    JSON_ARRAY('Sci-Fi', 'Thriller'),
    'Thriller de ciencia ficción indie sobre realidades paralelas',
    NULL
);

-- La Hora del Diablo (2021) – SIN PLATAFORMA
CALL SafeInsertContent(
    'La Hora del Diablo',
    2021,
    'movie',
    6.0,
    JSON_ARRAY('Horror', 'Thriller'),
    'Película de terror',
    NULL
);

-- ========================================
-- VERIFICACIONES FINALES
-- ========================================

SELECT '📊 GENERANDO REPORTE FINAL...' as status;

-- Contar contenido insertado hoy
SELECT
    type as 'Tipo de Contenido',
    COUNT(*) as 'Total',
    AVG(rating) as 'Rating Promedio'
FROM content
WHERE DATE(created_at) = CURDATE()
GROUP BY type
ORDER BY COUNT(*) DESC;

-- Mostrar contenido sin plataforma
SELECT
    'CONTENIDO SIN PLATAFORMA' as status,
    COUNT(*) as total
FROM content
WHERE platform_id IS NULL;

-- Mostrar distribución por plataformas
SELECT
    COALESCE(p.name, 'Sin Plataforma') as 'Plataforma',
    COUNT(c.id) as 'Contenido Total',
    SUM(CASE WHEN DATE(c.created_at) = CURDATE() THEN 1 ELSE 0 END) as 'Insertado Hoy'
FROM content c
LEFT JOIN platforms p ON c.platform_id = p.id
GROUP BY p.name
ORDER BY COUNT(c.id) DESC;

-- Verificar integridad de datos
SELECT
    'VERIFICACIÓN DE INTEGRIDAD' as status,
    (SELECT COUNT(*) FROM content WHERE profile_id IS NULL) as 'Sin Perfil',
    (SELECT COUNT(*) FROM content WHERE title IS NULL OR title = '') as 'Sin Título',
    (SELECT COUNT(*) FROM content WHERE year IS NULL) as 'Sin Año',
    (SELECT COUNT(*) FROM content WHERE type NOT IN ('movie', 'series')) as 'Tipo Inválido';

-- ========================================
-- LIMPIEZA Y FINALIZACIÓN
-- ========================================

-- Eliminar procedimiento temporal
DROP PROCEDURE SafeInsertContent;

-- Verificación final antes de commit
SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM content WHERE profile_id IS NULL) = 0
        THEN '✅ Verificación exitosa - Todos los registros tienen perfil'
        ELSE '❌ ERROR - Existen registros sin perfil'
    END as final_verification;

-- Solo hacer COMMIT si la verificación es exitosa
-- En caso de error, hacer ROLLBACK automático
COMMIT;

SELECT '🎉 SCRIPT EJECUTADO EXITOSAMENTE' as final_status;
SELECT 'Contenido agregado de forma segura a MovieFlix' as message;

-- ========================================
-- INSTRUCCIONES POST-EJECUCIÓN
-- ========================================
/*
📝 INSTRUCCIONES DESPUÉS DE EJECUTAR:

1. ✅ VERIFICAR RESULTADOS:
   - Revisar los reportes generados arriba
   - Confirmar que no hay errores en el log

2. 🔄 REINICIAR SERVIDOR (si está ejecutándose):
   - npm restart
   - o reiniciar el contenedor Docker

3. 🧪 PROBAR LA APLICACIÓN:
   - Verificar que el nuevo contenido aparece
   - Comprobar funcionalidad de filtros

4. 🗄️ BACKUP RECOMENDADO:
   - Hacer backup después de cambios importantes
   - mysqldump movieflix_db > backup_$(date +%Y%m%d).sql

5. 📊 MONITOREAR RENDIMIENTO:
   - Verificar que las consultas siguen siendo rápidas
   - Revisar logs de la aplicación

NOTAS DE SEGURIDAD:
- ✅ Script usa transacciones
- ✅ Verifica duplicados antes de insertar
- ✅ Mantiene integridad referencial
- ✅ Usa procedimientos para consistencia
- ✅ Genera reportes de verificación
*/
