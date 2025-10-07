#!/bin/bash

echo "=== TESTING ALL COMMANDS ==="

# Проверяем доступность всех команд
echo "1. Available commands:"
docker compose exec app php artisan list | grep -E "(company:|account:|token:|api-service:|token-type:|wb:fetch)"

# Тестируем создание компании
echo ""
echo "2. Testing company creation:"
docker compose exec app php artisan company:create "Test Company Commands" "Test company for command testing"

# Тестируем создание аккаунта
echo ""
echo "3. Testing account creation:"
docker compose exec app php artisan account:create 1 "Test Account Commands"

# Тестируем создание типа токена
echo ""
echo "4. Testing token type creation:"
docker compose exec app php artisan token-type:create "test-token-type" "Test token type"

# Тестируем создание API сервиса
echo ""
echo "5. Testing API service creation:"
docker compose exec app php artisan api-service:create "TestAPI" "http://test.api.com" "1"

# Тестируем создание токена
echo ""
echo "6. Testing token creation:"
docker compose exec app php artisan token:create 3 3 15 "test-token-value" "Test Token"

# Проверяем результаты
echo ""
echo "7. Checking created data:"
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'Companies:' as ''; SELECT * FROM companies ORDER BY id DESC LIMIT 1;
SELECT 'Accounts:' as ''; SELECT * FROM accounts ORDER BY id DESC LIMIT 1;
SELECT 'Token types:' as ''; SELECT * FROM token_types ORDER BY id DESC LIMIT 1;
SELECT 'API services:' as ''; SELECT * FROM api_services ORDER BY id DESC LIMIT 1;
SELECT 'Tokens:' as ''; SELECT * FROM tokens ORDER BY id DESC LIMIT 1;
"

echo "Command testing completed!"
