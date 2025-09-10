-- ========================================
-- MOVIEFLIX - INSERCIÓN SIMPLE Y SEGURA
-- ========================================
-- Script simplificado para MySQL 8.0

-- Configuración de seguridad
SET autocommit = 0;
SET foreign_key_checks = 1;

-- Iniciar transacción
START TRANSACTION;

-- Obtener el ID del perfil Home
SET @home_profile_id = (SELECT id FROM profiles WHERE name = 'Home' LIMIT 1);

-- Verificar que existe el perfil
SELECT 
    CASE 
        WHEN @home_profile_id IS NOT NULL 
        THEN CONCAT('✅ Perfil Home encontrado con ID: ', @home_profile_id)
        ELSE '❌ ERROR: Perfil Home no encontrado'
    END as verification_status;

-- ========================================
-- INSERCIÓN DE SERIES FALTANTES
-- ========================================

-- The Pitt (2025) – HBO
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'The Pitt', 2025, 'series', 8.9, 
       JSON_ARRAY('Drama'), 
       'Serie dramtica médica ambientada en un hospital de emergencias', 
       (SELECT id FROM platforms WHERE name = 'HBO' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'the pitt' AND year = 2025 AND type = 'series'
);

-- When They See Us (2019) – Netflix
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'When They See Us', 2019, 'series', 8.8, 
       JSON_ARRAY('Crime', 'Drama'), 
       'Miniserie sobre el caso Central Park Five', 
       (SELECT id FROM platforms WHERE name = 'Netflix' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'when they see us' AND year = 2019 AND type = 'series'
);

-- La Maravillosa Sra. Maisel (2017) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'La Maravillosa Sra. Maisel', 2017, 'series', 8.7, 
       JSON_ARRAY('Comedy', 'Drama'), 
       'Serie sobre una mujer que se convierte en comediante en los años 50', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'la maravillosa sra. maisel' AND year = 2017 AND type = 'series'
);

-- This Is Us (2016) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'This Is Us', 2016, 'series', 8.7, 
       JSON_ARRAY('Drama', 'Romance'), 
       'Drama familiar multigeneracional', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'this is us' AND year = 2016 AND type = 'series'
);

-- Dopesick (2021) – Disney+
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Dopesick', 2021, 'series', 8.6, 
       JSON_ARRAY('Drama', 'Crime'), 
       'Miniserie sobre la crisis de opioides en Estados Unidos', 
       (SELECT id FROM platforms WHERE name = 'Disney+' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'dopesick' AND year = 2021 AND type = 'series'
);

-- The Expanse (2015) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'The Expanse', 2015, 'series', 8.5, 
       JSON_ARRAY('Sci-Fi', 'Drama'), 
       'Serie de ciencia ficción espacial', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'the expanse' AND year = 2015 AND type = 'series'
);

-- Billions (2016) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Billions', 2016, 'series', 8.4, 
       JSON_ARRAY('Drama', 'Crime'), 
       'Drama sobre finanzas y poder en Wall Street', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'billions' AND year = 2016 AND type = 'series'
);

-- High Maintenance (2016) – HBO
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'High Maintenance', 2016, 'series', 8.1, 
       JSON_ARRAY('Comedy', 'Drama'), 
       'Serie antolgggica sobre un dealer de marihuana en Nueva York', 
       (SELECT id FROM platforms WHERE name = 'HBO' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'high maintenance' AND year = 2016 AND type = 'series'
);

-- Wild Wild Country (2018) – Netflix
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Wild Wild Country', 2018, 'series', 8.1, 
       JSON_ARRAY('Documentary'), 
       'Documental sobre el culto Rajneesh en Oregon', 
       (SELECT id FROM platforms WHERE name = 'Netflix' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'wild wild country' AND year = 2018 AND type = 'series'
);

-- Tokyo Vice (2022) – HBO
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Tokyo Vice', 2022, 'series', 8.1, 
       JSON_ARRAY('Crime', 'Drama', 'Thriller'), 
       'Drama criminal ambientado en el Tokio de los 90s', 
       (SELECT id FROM platforms WHERE name = 'HBO' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'tokyo vice' AND year = 2022 AND type = 'series'
);

-- The Morning Show (2019) – Apple TV+
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'The Morning Show', 2019, 'series', 8.1, 
       JSON_ARRAY('Drama'), 
       'Drama sobre un programa matutino de televisión', 
       (SELECT id FROM platforms WHERE name = 'Apple TV+' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'the morning show' AND year = 2019 AND type = 'series'
);

-- Slow Horses (2022) – Apple TV+
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Slow Horses', 2022, 'series', 7.5, 
       JSON_ARRAY('Drama', 'Spy'), 
       'Serie de espías británicos sobre agentes caídos en desgracia', 
       (SELECT id FROM platforms WHERE name = 'Apple TV+' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'slow horses' AND year = 2022 AND type = 'series'
);

-- ========================================
-- INSERCIÓN DE PELÍCULAS FALTANTES
-- ========================================

-- El Hombre que Mató a Liberty Valance (1962) – Disney+
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'El Hombre que Mató a Liberty Valance', 1962, 'movie', 8.1, 
       JSON_ARRAY('Western', 'Drama'), 
       'Western clásico de John Ford', 
       (SELECT id FROM platforms WHERE name = 'Disney+' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'el hombre que mató a liberty valance' AND year = 1962 AND type = 'movie'
);

-- Centauros del Desierto (1956) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Centauros del Desierto', 1956, 'movie', 8.0, 
       JSON_ARRAY('Western'), 
       'Western clásico de John Ford con John Wayne', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'centauros del desierto' AND year = 1956 AND type = 'movie'
);

-- Solo Ante el Peligro (1952) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Solo Ante el Peligro', 1952, 'movie', 7.5, 
       JSON_ARRAY('Western'), 
       'Western clásico con Gary Cooper', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'solo ante el peligro' AND year = 1952 AND type = 'movie'
);

-- Perfect Blue (1997) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Perfect Blue', 1997, 'movie', 8.0, 
       JSON_ARRAY('Animation', 'Thriller'), 
       'Thriller psicológico animado de Satoshi Kon', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'perfect blue' AND year = 1997 AND type = 'movie'
);

-- Castle in the Sky (1986) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Castle in the Sky', 1986, 'movie', 8.0, 
       JSON_ARRAY('Animation', 'Adventure', 'Family'), 
       'Película de Studio Ghibli sobre una ciudad flotante', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'castle in the sky' AND year = 1986 AND type = 'movie'
);

-- The Tale of the Princess Kaguya (2013) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'The Tale of the Princess Kaguya', 2013, 'movie', 8.0, 
       JSON_ARRAY('Animation', 'Drama', 'Fantasy'), 
       'Película de Studio Ghibli basada en el cuento japonés', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'the tale of the princess kaguya' AND year = 2013 AND type = 'movie'
);

-- Porco Rosso (1992) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Porco Rosso', 1992, 'movie', 7.7, 
       JSON_ARRAY('Animation', 'Adventure', 'Comedy'), 
       'Película de Studio Ghibli sobre un piloto convertido en cerdo', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'porco rosso' AND year = 1992 AND type = 'movie'
);

-- Doctor Zhivago ( HBO1965) 
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Doctor Zhivago', 1965, 'movie', 8.0, 
       JSON_ARRAY('Romance', 'Drama', 'War'), 
       'Épica romántica de David Lean', 
       (SELECT id FROM platforms WHERE name = 'HBO' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'doctor zhivago' AND year = 1965 AND type = 'movie'
);

-- Trece Vidas (2022) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Trece Vidas', 2022, 'movie', 7.8, 
       JSON_ARRAY('Biography', 'Drama', 'Thriller'), 
       'Drama sobre el rescate de niños en una cueva de Tailandia', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'trece vidas' AND year = 2022 AND type = 'movie'
);

-- La Cinta Blanca (2009) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'La Cinta Blanca', 2009, 'movie', 7.8, 
       JSON_ARRAY('Drama', 'Mystery'), 
       'Drama alemán de Michael Haneke', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'la cinta blanca' AND year = 2009 AND type = 'movie'
);

-- The Florida Project (2017) – Netflix
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'The Florida Project', 2017, 'movie', 7.6, 
       JSON_ARRAY('Drama'), 
       'Drama independiente sobre la pobreza infantil', 
       (SELECT id FROM platforms WHERE name = 'Netflix' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'the florida project' AND year = 2017 AND type = 'movie'
);

-- Contratiempo (2016) – Netflix
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Contratiempo', 2016, 'movie', 7.6, 
       JSON_ARRAY('Thriller', 'Crime', 'Drama'), 
       'Thriller español de Oriol Paulo', 
       (SELECT id FROM platforms WHERE name = 'Netflix' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'contratiempo' AND year = 2016 AND type = 'movie'
);

-- Cría Cuervos (1976) – Filmin
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Cría Cuervos', 1976, 'movie', 7.6, 
       JSON_ARRAY('Drama'), 
       'Drama español de Carlos Saura', 
       (SELECT id FROM platforms WHERE name = 'Filmin' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'cría cuervos' AND year = 1976 AND type = 'movie'
);

-- Que Dios Nos Perdone (2016) – Netflix
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Que Dios Nos Perdone', 2016, 'movie', 7.3, 
       JSON_ARRAY('Crime', 'Drama', 'Thriller'), 
       'Thriller policial español de Rodrigo Sorogoyen', 
       (SELECT id FROM platforms WHERE name = 'Netflix' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'que dios nos perdone' AND year = 2016 AND type = 'movie'
);

-- Tetris (2023) – Apple TV+
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Tetris', 2023, 'movie', 7.0, 
       JSON_ARRAY('Drama'), 
       'Drama sobre la historia del videojuego Tetris', 
       (SELECT id FROM platforms WHERE name = 'Apple TV+' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'tetris' AND year = 2023 AND type = 'movie'
);

-- First Blood (1982) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'First Blood', 1982, 'movie', 7.7, 
       JSON_ARRAY('Action'), 
       'Primera película de Rambo con Sylvester Stallone', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'first blood' AND year = 1982 AND type = 'movie'
);

-- Dredd (2012) – Prime Video
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Dredd', 2012, 'movie', 7.1, 
       JSON_ARRAY('Action', 'Sci-Fi'), 
       'Película de acción de ciencia ficción', 
       (SELECT id FROM platforms WHERE name = 'Prime Video' LIMIT 1),
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'dredd' AND year = 2012 AND type = 'movie'
);

-- Coherence (2013) – Sin plataforma
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'Coherence', 2013, 'movie', 7.2, 
       JSON_ARRAY('Sci-Fi', 'Thriller'), 
       'Thriller de ciencia ficción indie sobre realidades paralelas', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'coherence' AND year = 2013 AND type = 'movie'
);

-- La Hora del Diablo ( Sin plataforma2021) 
INSERT IGNORE INTO content (title, year, type, rating, genres, overview, platform_id, profile_id, status)
SELECT 'La Hora del Diablo', 2021, 'movie', 6.0, 
       JSON_ARRAY('Horror', 'Thriller'), 
       'Película de terror', 
       NULL,
       @home_profile_id, 'pending'
WHERE NOT EXISTS (
    SELECT 1 FROM content 
    WHERE LOWER(TRIM(title)) = 'la hora del diablo' AND year = 2021 AND type = 'movie'
);

-- ========================================
-- VERIFICACIONES FINALES
-- ========================================

-- Contar contenido insertado
SELECT 
    type as 'Tipo',
    COUNT(*) as 'Total',
    ROUND(AVG(rating), 1) as 'Rating Promedio'
FROM content 
GROUP BY type
ORDER BY COUNT(*) DESC;

-- Mostrar distribución por plataformas
SELECT 
    COALESCE(p.name, 'Sin Plataforma') as 'Plataforma',
    COUNT(c.id) as 'Total Contenido'
FROM content c
LEFT JOIN platforms p ON c.platform_id = p.id
GROUP BY p.name
ORDER BY COUNT(c.id) DESC;

-- Verificar integridad final
SELECT 
    'VERIFICACIÓN FINAL' as status,
    (SELECT COUNT(*) FROM content WHERE profile_id IS NULL) as 'Sin Perfil',
    (SELECT COUNT(*) FROM content WHERE title IS NULL OR title = '') as 'Sin Título',
    (SELECT COUNT(*) FROM content WHERE year IS NULL) as 'Sin Año';

-- Confirmar transacción
COMMIT;

SELECT '�� CONTENIDO AGREGADO EXITOSAMENTE' as final_status;
