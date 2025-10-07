#!/bin/bash

echo "=== FINAL COMPLETE TEST ==="

# 1. Проверяем все команды создания
echo "1. Testing all creation commands..."
docker compose exec app php artisan company:create "Final Test Company" "Company for final testing"
docker compose exec app php artisan account:create 4 "Final Test Account"
docker compose exec app php artisan token:create 4 1 1 "final-test-token" "Final Test Token"

# 2. Проверяем загрузку данных
echo ""
echo "2. Testing data loading..."
docker compose exec app php artisan wb:fetch sales --dateFrom=2025-10-06 --account=1
docker compose exec app php artisan wb:fetch orders --dateFrom=2025-10-06 --account=1
docker compose exec app php artisan wb:fetch stocks --dateFrom=2025-10-07 --account=1
docker compose exec app php artisan wb:fetch incomes --dateFrom=2025-10-06 --account=1

# 3. Проверяем итоговые данные
echo ""
echo "3. Final data check..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'Final data summary:' as '';
SELECT
    (SELECT COUNT(*) FROM companies) as companies,
    (SELECT COUNT(*) FROM accounts) as accounts,
    (SELECT COUNT(*) FROM tokens) as tokens,
    (SELECT COUNT(*) FROM sales) as sales,
    (SELECT COUNT(*) FROM orders) as orders,
    (SELECT COUNT(*) FROM stocks) as stocks,
    (SELECT COUNT(*) FROM incomes) as incomes;

SELECT 'Latest records by date:' as '';
SELECT 'Sales:' as type, MAX(date) as latest_date FROM sales
UNION ALL SELECT 'Orders:', MAX(date) FROM orders
UNION ALL SELECT 'Stocks:', MAX(date) FROM stocks
UNION ALL SELECT 'Incomes:', MAX(date) FROM incomes;
"

echo "Final testing completed!"
