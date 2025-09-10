-- Script para agregar contenido faltante y limpiar asociaciones con plataformas eliminadas

-- Primero, vamos a actualizar el contenido que estaba asociado a Criterion Channel y Shudder para que no tenga plataforma
UPDATE content SET platform_id = NULL WHERE platform_id IN (9, 10);

-- Verificar que las plataformas Criterion Channel y Shudder fueron eliminadas
-- DELETE FROM platforms WHERE name IN ('Criterion Channel', 'Shudder'); -- Ya ejecutado

-- Agregar contenido faltante de la lista
-- Series principales que faltan:

-- The Pitt (2025) – HBO
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('The Pitt', 'series', 2025, 8.9, '["Drama"]', 'Serie dramática médica', 2, 'pending');

-- When They See Us (2019) – Netflix
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('When They See Us', 'series', 2019, 8.8, '["Crime", "Drama"]', 'Miniserie sobre el caso Central Park Five', 1, 'pending');

-- La Maravillosa Sra. Maisel (2017–2023) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('La Maravillosa Sra. Maisel', 'series', 2017, 8.7, '["Comedy", "Drama"]', 'Serie sobre una mujer que se convierte en comediante', 3, 'pending');

-- This Is Us (2016–2022) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('This Is Us', 'series', 2016, 8.7, '["Drama", "Romance"]', 'Drama familiar multigeneracional', 3, 'pending');

-- Dopesick (2021) – Disney+
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Dopesick', 'series', 2021, 8.6, '["Drama", "Crime"]', 'Miniserie sobre la crisis de opioides', 5, 'pending');

-- The Expanse (2015-2022) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('The Expanse', 'series', 2015, 8.5, '["Sci-Fi", "Drama"]', 'Serie de ciencia ficción espacial', 3, 'pending');

-- Billions (2016–2023) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Billions', 'series', 2016, 8.4, '["Drama", "Crime"]', 'Drama sobre finanzas y poder', 3, 'pending');

-- High Maintenance – HBO
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('High Maintenance', 'series', 2016, 8.1, '["Comedy", "Drama"]', 'Serie antológica sobre un dealer de marihuana', 2, 'pending');

-- Wild Wild Country (2018) – Netflix
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Wild Wild Country', 'series', 2018, 8.1, '["Documentary"]', 'Documental sobre el culto Rajneesh', 1, 'pending');

-- Tokyo Vice (2022–2024) – HBO Max
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Tokyo Vice', 'series', 2022, 8.1, '["Crime", "Drama", "Thriller"]', 'Drama criminal ambientado en Tokio', 2, 'pending');

-- The Morning Show (2019– ) – Apple TV+
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('The Morning Show', 'series', 2019, 8.1, '["Drama"]', 'Drama sobre un programa matutino de televisión', 4, 'pending');

-- Slow Horses (2022– ) – Apple TV+
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Slow Horses', 'series', 2022, 7.5, '["Drama", "Spy"]', 'Serie de espías británicos', 4, 'pending');

-- PELÍCULAS QUE FALTAN:

-- El Hombre que Mató a Liberty Valance (1962) – Disney+
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('El Hombre que Mató a Liberty Valance', 'movie', 1962, 8.1, '["Western", "Drama"]', 'Western clásico de John Ford', 5, 'pending');

-- Centauros del Desierto (1956) – SIN PLATAFORMA (era Criterion Channel)
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Centauros del Desierto', 'movie', 1956, 8.0, '["Western"]', 'Western clásico de John Ford', NULL, 'pending');

-- Solo Ante el Peligro (1952) – SIN PLATAFORMA (era Criterion Channel)
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Solo Ante el Peligro', 'movie', 1952, 7.5, '["Western"]', 'Western clásico con Gary Cooper', NULL, 'pending');

-- Perfect Blue (1997) – SIN PLATAFORMA
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Perfect Blue', 'movie', 1997, 8.0, '["Animation", "Thriller"]', 'Thriller psicológico animado', NULL, 'pending');

-- Castle in the Sky (1986) – SIN PLATAFORMA
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Castle in the Sky', 'movie', 1986, 8.0, '["Animation", "Adventure", "Family"]', 'Película de Studio Ghibli', NULL, 'pending');

-- The Tale of the Princess Kaguya (2013) – SIN PLATAFORMA
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('The Tale of the Princess Kaguya', 'movie', 2013, 8.0, '["Animation", "Drama", "Fantasy"]', 'Película de Studio Ghibli', NULL, 'pending');

-- Porco Rosso (1992) – SIN PLATAFORMA
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Porco Rosso', 'movie', 1992, 7.7, '["Animation", "Adventure", "Comedy"]', 'Película de Studio Ghibli', NULL, 'pending');

-- Doctor Zhivago (1965) – HBO Max
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Doctor Zhivago', 'movie', 1965, 8.0, '["Romance", "Drama", "War"]', 'Épica romántica de David Lean', 2, 'pending');

-- Trece Vidas (2022) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Trece Vidas', 'movie', 2022, 7.8, '["Biography", "Drama", "Thriller"]', 'Drama sobre el rescate en Tailandia', 3, 'pending');

-- La Cinta Blanca (2009) – SIN PLATAFORMA (era Criterion Channel)
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('La Cinta Blanca', 'movie', 2009, 7.8, '["Drama", "Mystery"]', 'Drama alemán de Michael Haneke', NULL, 'pending');

-- The Florida Project (2017) – Netflix
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('The Florida Project', 'movie', 2017, 7.6, '["Drama"]', 'Drama independiente sobre la pobreza infantil', 1, 'pending');

-- Contratiempo (2016) – Netflix
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Contratiempo', 'movie', 2016, 7.6, '["Thriller", "Crime", "Drama"]', 'Thriller español', 1, 'pending');

-- Cría Cuervos (1976) – Filmin
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Cría Cuervos', 'movie', 1976, 7.6, '["Drama"]', 'Drama español de Carlos Saura', 8, 'pending');

-- Que Dios Nos Perdone (2016) – Netflix
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Que Dios Nos Perdone', 'movie', 2016, 7.3, '["Crime", "Drama", "Thriller"]', 'Thriller policial español', 1, 'pending');

-- Tetris (2023) – Apple TV+
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Tetris', 'movie', 2023, 7.0, '["Drama"]', 'Drama sobre la historia del videojuego Tetris', 4, 'pending');

-- Tierra de Mafiosos (2024) – Movistar+
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Tierra de Mafiosos', 'movie', 2024, 6.4, '["Crime", "Thriller"]', 'Thriller criminal español', 7, 'pending');

-- First Blood (1982) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('First Blood', 'movie', 1982, 7.7, '["Action"]', 'Primera película de Rambo', 3, 'pending');

-- Dredd (2012) – Prime Video
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Dredd', 'movie', 2012, 7.1, '["Action", "Sci-Fi"]', 'Película de acción de ciencia ficción', 3, 'pending');

-- Coherence (2013) – SIN PLATAFORMA
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('Coherence', 'movie', 2013, 7.2, '["Sci-Fi", "Thriller"]', 'Thriller de ciencia ficción indie', NULL, 'pending');

-- Películas de terror que estaban en Shudder -> SIN PLATAFORMA
-- La Hora del Diablo (2021) – era Shudder
INSERT IGNORE INTO content (title, type, year, rating, genres, overview, platform_id, status)
VALUES ('La Hora del Diablo', 'movie', 2021, 6.0, '["Horror", "Thriller"]', 'Película de terror', NULL, 'pending');
