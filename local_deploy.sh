#!/bin/bash

echo "=== LOCAL DEPLOYMENT ==="

# Проверяем установлен ли Docker
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker Desktop from:"
    echo "https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Останавливаем существующие контейнеры
docker compose down

# Запускаем проект
docker compose up -d

echo "Waiting for containers to start..."
sleep 30

# Проверяем статус
echo "=== DEPLOYMENT STATUS ==="
docker-compose ps

echo "=== DATABASE CHECK ==="
docker-compose exec db mysql -u wb_user -pwb_password wb_sale -e "SHOW TABLES;"

echo "=== APPLICATION READY ==="
echo "MySQL is running on: localhost:3307"
echo "You can test data fetching:"
echo "docker-compose exec app php artisan wb:fetch stocks --dateFrom=2025-10-06"
echo ""
echo "Access MySQL directly:"
echo "mysql -h 127.0.0.1 -P 3307 -u wb_user -pwb_password wb_sale"
