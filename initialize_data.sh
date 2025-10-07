#!/bin/bash
# initialize_data.sh

echo "Initializing Wildberries API data..."

# Создаем типы токенов
docker compose exec app php artisan token-type:create "api-key" "API Key authentication"
docker compose exec app php artisan token-type:create "bearer" "Bearer token authentication"
docker compose exec app php artisan token-type:create "basic-auth" "Basic authentication"
docker compose exec app php artisan token-type:create "oauth" "OAuth authentication"

# Создаем Wildberries API сервис
docker compose exec app php artisan api-service:create "Wildberries" "http://109.73.206.144:6969" "1"

echo "Data initialization completed!"
