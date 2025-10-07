#!/bin/bash

echo "=== CHECKING DATABASE RELATIONSHIPS ==="

# Проверяем структуру таблиц и связи
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
-- Проверяем внешние ключи
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_NAME IS NOT NULL
AND TABLE_SCHEMA = 'wb_sale';

-- Проверяем индексы
SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'wb_sale'
AND TABLE_NAME IN ('tokens', 'api_services', 'token_types')
ORDER BY TABLE_NAME, INDEX_NAME;
"
