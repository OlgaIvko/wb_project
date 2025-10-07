#!/bin/bash

echo "=== CHECKING UNIQUE KEYS ==="

docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
-- Проверяем уникальные ключи в tokens
SHOW INDEX FROM tokens WHERE Non_unique = 0;

-- Проверяем уникальные ключи в token_types
SHOW INDEX FROM token_types WHERE Non_unique = 0;

-- Проверяем уникальные ключи в api_services
SHOW INDEX FROM api_services WHERE Non_unique = 0;

-- Проверяем данные на дубликаты
SELECT 'Duplicate tokens:' as '';
SELECT account_id, api_service_id, COUNT(*)
FROM tokens
GROUP BY account_id, api_service_id
HAVING COUNT(*) > 1;

SELECT 'Duplicate token types:' as '';
SELECT name, COUNT(*)
FROM token_types
GROUP BY name
HAVING COUNT(*) > 1;

SELECT 'Duplicate api_services:' as '';
SELECT name, COUNT(*)
FROM api_services
GROUP BY name
HAVING COUNT(*) > 1;
"
