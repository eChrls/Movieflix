-- ===================================
-- SCRIPT PARA ARREGLAR PERMISOS DE BD
-- MovieFlix - CONFIGURACIÓN CORRECTA
-- Base de Datos: movieflix_db
-- Usuario: movieflix_user
-- Contraseña: movieflix_secure_2025!
-- ===================================

-- 1. Primero verificar que existe la base de datos
CREATE DATABASE IF NOT EXISTS movieflix_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Eliminar usuarios existentes para evitar conflictos
DROP USER IF EXISTS 'movieflix_user'@'localhost';
DROP USER IF EXISTS 'movieflix_user'@'%';
DROP USER IF EXISTS 'movieflix_user'@'192.168.1.50';

-- 3. Crear usuario movieflix_user con permisos para múltiples hosts
CREATE USER 'movieflix_user'@'localhost' IDENTIFIED BY 'movieflix_secure_2025!';
CREATE USER 'movieflix_user'@'%' IDENTIFIED BY 'movieflix_secure_2025!';
CREATE USER 'movieflix_user'@'192.168.1.50' IDENTIFIED BY 'movieflix_secure_2025!';

-- 4. Otorgar TODOS los permisos en movieflix_db
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'localhost';
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'%';
GRANT ALL PRIVILEGES ON movieflix_db.* TO 'movieflix_user'@'192.168.1.50';

-- 5. Aplicar cambios inmediatamente
FLUSH PRIVILEGES;

-- 6. Verificar que el usuario fue creado correctamente
SELECT 'Usuarios movieflix_user creados:' as Info;
SELECT user, host FROM mysql.user WHERE user = 'movieflix_user';

-- 7. Verificar permisos otorgados
SELECT 'Permisos otorgados:' as Info;
SHOW GRANTS FOR 'movieflix_user'@'localhost';
SHOW GRANTS FOR 'movieflix_user'@'%';

-- 8. Verificar que la base de datos movieflix_db existe
SELECT 'Base de datos movieflix_db:' as Info;
USE movieflix_db;
SHOW TABLES;

-- 9. Si hay tablas, mostrar algunos datos de ejemplo
SELECT 'Conteo de registros (si existen):' as Info;
SELECT
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'movieflix_db' AND table_name = 'content') as tabla_content_existe,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'movieflix_db' AND table_name = 'profiles') as tabla_profiles_existe;

COMMIT;
