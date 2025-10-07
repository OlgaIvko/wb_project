#!/bin/bash

echo "=== CHECKING DATA IN TABLES ==="

docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
-- Проверяем данные в основных таблицах
SELECT 'Companies:' as ''; SELECT * FROM companies;
SELECT 'Accounts:' as ''; SELECT * FROM accounts;
SELECT 'API Services:' as ''; SELECT * FROM api_services;
SELECT 'Token Types:' as ''; SELECT * FROM token_types;
SELECT 'Tokens:' as ''; SELECT * FROM tokens;

-- Проверяем данные в таблицах с данными
SELECT 'Sales count:' as ''; SELECT COUNT(*) as count FROM sales;
SELECT 'Orders count:' as ''; SELECT COUNT(*) as count FROM orders;
SELECT 'Stocks count:' as ''; SELECT COUNT(*) as count FROM stocks;
SELECT 'Incomes count:' as ''; SELECT COUNT(*) as count FROM incomes;

-- Проверяем последние даты обновления
SELECT 'Latest dates:' as '';
SELECT 'Sales:' as table_name, MAX(date) as latest_date FROM sales
UNION ALL
SELECT 'Orders:', MAX(date) FROM orders
UNION ALL
SELECT 'Stocks:', MAX(date) FROM stocks
UNION ALL
SELECT 'Incomes:', MAX(date) FROM incomes;
"
