-- ========================================
-- SCRIPT DE INSERCIÓN SEGURA MOVIEFLIX_DB
-- ========================================
-- Este script inserta títulos únicamente si no existen previamente
-- Utiliza transacciones y manejo de errores para garantizar integridad

-- Iniciar transacción
START TRANSACTION;

-- Crear tabla temporal para mapear plataformas si no existe
CREATE TEMPORARY TABLE temp_platforms AS
SELECT 1 as platform_id, 'HBO' as platform_name
UNION SELECT 2, 'Netflix'
UNION SELECT 3, 'Prime Video'
UNION SELECT 4, 'Apple TV+'
UNION SELECT 5, 'Disney+'
UNION SELECT 6, 'HBO Max'
UNION SELECT 7, 'SkyShowtime'
UNION SELECT 8, 'Criterion Channel'
UNION SELECT 9, 'Movistar+'
UNION SELECT 10, 'Filmin'
UNION SELECT 11, 'Shudder'
UNION SELECT 12, 'Amazon Prime';

-- ========================================
-- SERIES
-- ========================================

-- Band of Brothers (2001)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Band of Brothers', 'Series', 2001,
       COALESCE((SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO'), NULL)
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'band of brothers' AND year = 2001
);

-- Death Note (2006-2007)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Death Note', 'Series', 2006, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'death note' AND year = 2006
);

-- The Pitt (2025)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'The Pitt', 'Series', 2025,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'the pitt' AND year = 2025
);

-- When They See Us (2019)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'When They See Us', 'Series', 2019,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'when they see us' AND year = 2019
);

-- Dark (2017-2020)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Dark', 'Series', 2017,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'dark' AND year = 2017
);

-- Peaky Blinders (2013-2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Peaky Blinders', 'Series', 2013,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'peaky blinders' AND year = 2013
);

-- La Maravillosa Sra. Maisel (2017–2023)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'La Maravillosa Sra. Maisel', 'Series', 2017,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'la maravillosa sra. maisel' AND year = 2017
);

-- This Is Us (2016–2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'This Is Us', 'Series', 2016,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'this is us' AND year = 2016
);

-- Atlanta (2016-2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Atlanta', 'Series', 2016, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'atlanta' AND year = 2016
);

-- Dopesick (2021)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Dopesick', 'Series', 2021,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Disney+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'dopesick' AND year = 2021
);

-- Bron/Broen - The Bridge (2011-2018)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Bron/Broen - The Bridge', 'Series', 2011, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'bron/broen - the bridge' AND year = 2011
);

-- The Expanse (2015-2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'The Expanse', 'Series', 2015,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'the expanse' AND year = 2015
);

-- Treme (2010-2013)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Treme', 'Series', 2010, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'treme' AND year = 2010
);

-- Ozark (2017-2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Ozark', 'Series', 2017,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'ozark' AND year = 2017
);

-- Billions (2016–2023)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Billions', 'Series', 2016,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'billions' AND year = 2016
);

-- High Maintenance (2016–2020)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'High Maintenance', 'Series', 2016,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'high maintenance' AND year = 2016
);

-- Wild Wild Country (2018)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Wild Wild Country', 'Series', 2018,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'wild wild country' AND year = 2018
);

-- Tokyo Vice (2022–2024)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Tokyo Vice', 'Series', 2022,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO Max')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'tokyo vice' AND year = 2022
);

-- The Morning Show (2019–)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'The Morning Show', 'Series', 2019,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Apple TV+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'the morning show' AND year = 2019
);

-- Show Me a Hero (2015)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Show Me a Hero', 'Series', 2015,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'show me a hero' AND year = 2015
);

-- ZeroZeroZero (2019-2020)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'ZeroZeroZero', 'Series', 2019,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Amazon Prime')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'zerozerozerozero' AND year = 2019
);

-- Undone (2019–2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Undone', 'Series', 2019,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'undone' AND year = 2019
);

-- Crashing (2017-2019)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Crashing', 'Series', 2017,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO Max')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'crashing' AND year = 2017
);

-- Somebody Somewhere (2022–)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Somebody Somewhere', 'Series', 2022,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'somebody somewhere' AND year = 2022
);

-- Staircase (2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Staircase', 'Series', 2022,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'staircase' AND year = 2022
);

-- Slow Horses (2022–)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Slow Horses', 'Series', 2022,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Apple TV+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'slow horses' AND year = 2022
);

-- La Ciudad es Nuestra (2025)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'La Ciudad es Nuestra', 'Series', 2025,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'la ciudad es nuestra' AND year = 2025
);

-- CAEM (2024–)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'CAEM', 'Series', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'caem' AND year = 2024
);

-- Las Gotas de Dios (2023)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Las Gotas de Dios', 'Series', 2023,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Amazon Prime')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'las gotas de dios' AND year = 2023
);

-- Tierra de Mafiosos (2024)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Tierra de Mafiosos', 'Series', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Movistar+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'tierra de mafiosos' AND year = 2024
);

-- Yellowstone (2018–)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Yellowstone', 'Series', 2018,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'SkyShowtime')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'yellowstone' AND year = 2018
);

-- 1883 (2021–2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT '1883', 'Series', 2021,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'SkyShowtime')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = '1883' AND year = 2021
);

-- ========================================
-- PELÍCULAS
-- ========================================

-- El Hombre que Mató a Liberty Valance (1962)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'El Hombre que Mató a Liberty Valance', 'Movie', 1962,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Disney+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'el hombre que mató a liberty valance' AND year = 1962
);

-- Río Bravo (1959)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Río Bravo', 'Movie', 1959,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'SkyShowtime')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'río bravo' AND year = 1959
);

-- Centauros del Desierto (1956)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Centauros del Desierto', 'Movie', 1956,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Criterion Channel')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'centauros del desierto' AND year = 1956
);

-- Solo Ante el Peligro (1952)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Solo Ante el Peligro', 'Movie', 1952,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Criterion Channel')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'solo ante el peligro' AND year = 1952
);

-- Perfect Blue (1997)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Perfect Blue', 'Movie', 1997, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'perfect blue' AND year = 1997
);

-- Castle in the Sky (1986)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Castle in the Sky', 'Movie', 1986, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'castle in the sky' AND year = 1986
);

-- The Tale of the Princess Kaguya (2013)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'The Tale of the Princess Kaguya', 'Movie', 2013, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'the tale of the princess kaguya' AND year = 2013
);

-- Porco Rosso (1992)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Porco Rosso', 'Movie', 1992, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'porco rosso' AND year = 1992
);

-- Snack Shack (2019)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Snack Shack', 'Movie', 2019,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'snack shack' AND year = 2019
);

-- First Blood (1982)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'First Blood', 'Movie', 1982,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'first blood' AND year = 1982
);

-- Dredd (2012)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Dredd', 'Movie', 2012,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'dredd' AND year = 2012
);

-- Chacal (1997)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Chacal', 'Movie', 1997,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'chacal' AND year = 1997
);

-- Monkey Man (2024)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Monkey Man', 'Movie', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'monkey man' AND year = 2024
);

-- Akira (1988)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Akira', 'Movie', 1988,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'akira' AND year = 1988
);

-- 2001: A Space Odyssey (1968)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT '2001: A Space Odyssey', 'Movie', 1968, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = '2001: a space odyssey' AND year = 1968
);

-- Coherence (2013)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Coherence', 'Movie', 2013, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'coherence' AND year = 2013
);

-- Doctor Zhivago (1965)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Doctor Zhivago', 'Movie', 1965,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'HBO Max')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'doctor zhivago' AND year = 1965
);

-- Trece Vidas (2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Trece Vidas', 'Movie', 2022,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'trece vidas' AND year = 2022
);

-- La Cinta Blanca (2009)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'La Cinta Blanca', 'Movie', 2009,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Criterion Channel')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'la cinta blanca' AND year = 2009
);

-- The Florida Project (2017)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'The Florida Project', 'Movie', 2017,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'the florida project' AND year = 2017
);

-- Contratiempo (2016)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Contratiempo', 'Movie', 2016,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'contratiempo' AND year = 2016
);

-- Cría Cuervos (1976)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Cría Cuervos', 'Movie', 1976,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Filmin')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'cría cuervos' AND year = 1976
);

-- Cure (1997)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Cure', 'Movie', 1997, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'cure' AND year = 1997
);

-- Que Dios Nos Perdone (2016)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Que Dios Nos Perdone', 'Movie', 2016,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'que dios nos perdone' AND year = 2016
);

-- Mean Streets (1973)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Mean Streets', 'Movie', 1973,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'mean streets' AND year = 1973
);

-- Tetris (2023)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Tetris', 'Movie', 2023,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Apple TV+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'tetris' AND year = 2023
);

-- El Jockey (2021)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'El Jockey', 'Movie', 2021,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Prime Video')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'el jockey' AND year = 2021
);

-- Hermanas Hasta la Muerte (2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Hermanas Hasta la Muerte', 'Movie', 2022,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Filmin')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'hermanas hasta la muerte' AND year = 2022
);

-- The Rule of Jenny Penn (2024)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'The Rule of Jenny Penn', 'Movie', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Apple TV+')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'the rule of jenny penn' AND year = 2024
);

-- El Extraño (2013)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'El Extraño', 'Movie', 2013,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Amazon Prime')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'el extraño' AND year = 2013
);

-- Häxan: Witchcraft Through the Ages (1922)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Häxan: Witchcraft Through the Ages', 'Movie', 1922, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'häxan: witchcraft through the ages' AND year = 1922
);

-- High Tension (2003)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'High Tension', 'Movie', 2003, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'high tension' AND year = 2003
);

-- El Baño del Diablo (2024) - Filmin
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'El Baño del Diablo', 'Movie', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Filmin')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'el baño del diablo' AND year = 2024 AND platform_id = (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Filmin')
);

-- El Baño del Diablo (2024) - Netflix (versión diferente)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'El Baño del Diablo', 'Movie', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'el baño del diablo' AND year = 2024 AND platform_id = (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
);

-- Speak No Evil (2022)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'Speak No Evil', 'Movie', 2022, NULL
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'speak no evil' AND year = 2022
);

-- La Hora del Diablo (2021)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'La Hora del Diablo', 'Movie', 2021,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Shudder')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'la hora del diablo' AND year = 2021
);

-- La Casa (2024)
INSERT IGNORE INTO movieflix_db.titles (title, type, year, platform_id)
SELECT 'La Casa', 'Movie', 2024,
       (SELECT platform_id FROM temp_platforms WHERE platform_name = 'Netflix')
WHERE NOT EXISTS (
    SELECT 1 FROM movieflix_db.titles
    WHERE LOWER(TRIM(title)) = 'la casa' AND year = 2024
);

-- ========================================
-- VERIFICACIÓN Y REPORTE
-- ========================================

-- Mostrar resumen de títulos insertados por tipo
SELECT
    type as 'Tipo',
    COUNT(*) as 'Total Insertado',
    GROUP_CONCAT(DISTINCT IFNULL(tp.platform_name, 'Sin Plataforma') SEPARATOR ', ') as 'Plataformas'
FROM movieflix_db.titles t
LEFT JOIN temp_platforms tp ON t.platform_id = tp.platform_id
WHERE t.created_date >= CURDATE()  -- Solo los insertados hoy
GROUP BY type
ORDER BY COUNT(*) DESC;

-- Mostrar títulos duplicados potenciales (mismo nombre, diferente año)
SELECT
    title,
    COUNT(*) as 'Versiones',
    GROUP_CONCAT(year ORDER BY year SEPARATOR ', ') as 'Años',
    GROUP_CONCAT(DISTINCT IFNULL(tp.platform_name, 'Sin Plataforma') SEPARATOR ', ') as 'Plataformas'
FROM movieflix_db.titles t
LEFT JOIN temp_platforms tp ON t.platform_id = tp.platform_id
GROUP BY LOWER(TRIM(title))
HAVING COUNT(*) > 1
ORDER BY title;

-- Mostrar estadísticas finales
SELECT
    'RESUMEN FINAL' as 'Status',
    (SELECT COUNT(*) FROM movieflix_db.titles WHERE type = 'Series') as 'Total Series',
    (SELECT COUNT(*) FROM movieflix_db.titles WHERE type = 'Movie') as 'Total Películas',
    (SELECT COUNT(*) FROM movieflix_db.titles) as 'Total General';

-- ========================================
-- LIMPIEZA
-- ========================================

-- Eliminar tabla temporal
DROP TEMPORARY TABLE temp_platforms;

-- Confirmar transacción
COMMIT;

-- ========================================
-- NOTAS DE SEGURIDAD Y USO
-- ========================================
/*
INSTRUCCIONES DE USO:
1. Revisar que la estructura de tu tabla 'titles' coincida con las columnas utilizadas
2. Ajustar los platform_id según tu tabla de plataformas existente
3. Ejecutar este script en un entorno de prueba primero
4. Verificar los resultados con las consultas de verificación incluidas

CARACTERÍSTICAS DE SEGURIDAD:
- Uso de INSERT IGNORE para evitar errores por duplicados
- Transacciones para mantener integridad
- Verificaciones EXISTS para prevenir duplicados
- Comparación case-insensitive con LOWER() y TRIM()
- Uso de COALESCE para manejar valores NULL
- Tabla temporal para mapear plataformas

DUPLICADOS ESPECIALES IDENTIFICADOS:
- "El Baño del Diablo" (2024) aparece en Filmin y Netflix (posiblemente versiones diferentes)
- Se manejan como entradas separadas basadas en plataforma

CONSIDERACIONES:
- Los títulos sin plataforma específica tendrán platform_id = NULL
- Se recomienda revisar y actualizar los platform_id según tu esquema
- Los años de series multi-temporada usan el año de inicio
*/
