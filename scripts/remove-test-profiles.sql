-- Script para eliminar perfiles de prueba no deseados
-- Ejecutar: mysql -u movieflix_user -p movieflix_db < scripts/remove-test-profiles.sql

-- Eliminar contenido asociado a perfiles de prueba
DELETE FROM content WHERE profile_id IN (
    SELECT id FROM profiles WHERE name IN ('Prueba', 'TestSinPin')
);

-- Eliminar los perfiles de prueba
DELETE FROM profiles WHERE name IN ('Prueba', 'TestSinPin');

-- Verificar perfiles restantes
SELECT id, name, emoji, created_at FROM profiles ORDER BY created_at ASC;
