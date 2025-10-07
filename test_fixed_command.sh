#!/bin/bash
echo "=== ТЕСТИРОВАНИЕ ИСПРАВЛЕННОЙ КОМАНДЫ ==="

echo -e "\n1. Тестируем команду для продаж:"
docker compose exec app php artisan wb:fetch sales --dateFrom=$(date -v-1d +%Y-%m-%d)

echo -e "\n2. Тестируем команду для заказов:"
docker compose exec app php artisan wb:fetch orders --dateFrom=$(date -v-1d +%Y-%m-%d)

echo -e "\n3. Тестируем команду для остатков:"
docker compose exec app php artisan wb:fetch stocks --dateFrom=$(date +%Y-%m-%d)

echo -e "\n4. Тестируем команду для поступлений:"
docker compose exec app php artisan wb:fetch incomes --dateFrom=$(date -v-1d +%Y-%m-%d)

echo -e "\n5. Тестируем команду для конкретного аккаунта:"
docker compose exec app php artisan wb:fetch sales --dateFrom=$(date -v-1d +%Y-%m-%d) --account=1

