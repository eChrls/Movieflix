-- ===================================
-- SCRIPT PARA ARREGLAR PERMISOS DE BD
-- MovieFlix - Fecha: 12 Sep 2025
-- ===================================

-- Problema: Usuario movieflix_user no puede conectar desde IP 192.168.1.50
-- Solución: Otorgar permisos para todas las IPs y específicamente para 192.168.1.50

-- 1. Crear/Actualizar usuario para permitir conexiones desde cualquier IP
DROP USER IF EXISTS 'movieflix_user'@'localhost';
DROP USER IF EXISTS 'movieflix_user'@'%';
DROP USER IF EXISTS 'movieflix_user'@'192.168.1.50';

-- 2. Crear usuario con permisos para múltiples hosts
CREATE USER 'movieflix_user'@'%' IDENTIFIED BY 'movieflix_secure_2025!';
CREATE USER 'movieflix_user'@'192.168.1.50' IDENTIFIED BY 'movieflix_secure_2025!';
CREATE USER 'movieflix_user'@'localhost' IDENTIFIED BY 'movieflix_secure_2025!';

-- 3. Otorgar todos los permisos en la base de datos movieflix_db
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'%';
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'192.168.1.50';
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'localhost';

-- 4. Aplicar cambios
FLUSH PRIVILEGES;

-- 5. Verificar permisos (comandos informativos)
-- SELECT user, host FROM mysql.user WHERE user = 'movieflix_user';
-- SHOW GRANTS FOR 'movieflix_user'@'%';
-- SHOW GRANTS FOR 'movieflix_user'@'192.168.1.50';

-- 6. Verificar que la BD y tablas existen
-- USE movieflix_db;
-- SHOW TABLES;
-- SELECT COUNT(*) FROM content;
-- SELECT COUNT(*) FROM profiles;

COMMIT;
