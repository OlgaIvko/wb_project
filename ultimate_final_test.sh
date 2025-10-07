#!/bin/bash

echo "=== ULTIMATE FINAL TEST ==="

# Тестируем все типы данных с исправленным кодом
echo "1. Testing all data types with fixed code..."
docker compose exec app php artisan wb:fetch sales --dateFrom=2025-10-06 --account=1
docker compose exec app php artisan wb:fetch orders --dateFrom=2025-10-06 --account=1
docker compose exec app php artisan wb:fetch stocks --dateFrom=2025-10-07 --account=1
docker compose exec app php artisan wb:fetch incomes --dateFrom=2025-10-06 --account=1

# Проверяем итоговые данные
echo ""
echo "2. Final data verification..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'ULTIMATE FINAL DATA COUNT:' as '';
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

SELECT 'Data freshness:' as '';
SELECT 'Sales:' as type, MAX(date) as latest_date FROM sales
UNION ALL SELECT 'Orders:', MAX(date) FROM orders
UNION ALL SELECT 'Stocks:', MAX(date) FROM stocks
UNION ALL SELECT 'Incomes:', MAX(date) FROM incomes;
"

echo ""
echo "3. Database structure check..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'Stocks table structure:' as '';
DESCRIBE stocks;
"

echo "Ultimate final test completed!"
