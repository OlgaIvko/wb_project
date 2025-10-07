#!/bin/bash

echo "=== FINAL COMPREHENSIVE CHECK ==="

# 1. Проверяем структуру базы данных
echo "1. Database structure check..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
-- Проверяем уникальные ключи
SELECT 'Unique indexes:' as '';
SHOW INDEX FROM token_types WHERE Non_unique = 0;
SHOW INDEX FROM api_services WHERE Non_unique = 0;
SHOW INDEX FROM tokens WHERE Non_unique = 0;

-- Проверяем связи
SELECT 'Foreign keys:' as '';
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'wb_sale'
AND REFERENCED_TABLE_NAME IS NOT NULL;
"

# 2. Проверяем отсутствие дубликатов
echo ""
echo "2. Duplicate check..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'Duplicate check:' as '';
SELECT 'Token types:' as table_name, COUNT(*) as total, COUNT(DISTINCT name) as unique_names FROM token_types
UNION ALL
SELECT 'API services:', COUNT(*), COUNT(DISTINCT name) FROM api_services
UNION ALL
SELECT 'Tokens:', COUNT(*), COUNT(DISTINCT CONCAT(account_id, '-', api_service_id)) FROM tokens;
"

# 3. Проверяем команды
echo ""
echo "3. Commands verification..."
docker compose exec app php artisan list | grep -E "(company:|account:|token:|api-service:|token-type:|wb:fetch)" | head -10

# 4. Проверяем данные
echo ""
echo "4. Data verification..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'Final data counts:' as '';
SELECT
    (SELECT COUNT(*) FROM companies) as companies,
    (SELECT COUNT(*) FROM accounts) as accounts,
    (SELECT COUNT(*) FROM api_services) as api_services,
    (SELECT COUNT(*) FROM token_types) as token_types,
    (SELECT COUNT(*) FROM tokens) as tokens,
    (SELECT COUNT(*) FROM sales) as sales,
    (SELECT COUNT(*) FROM orders) as orders,
    (SELECT COUNT(*) FROM stocks) as stocks,
    (SELECT COUNT(*) FROM incomes) as incomes;
"

# 5. Проверяем тесты
echo ""
echo "5. Tests verification..."
find tests/ -name "*.php" -type f | wc -l | xargs echo "Number of test files:"

echo ""
echo "=== ALL CHECKS COMPLETED ==="
