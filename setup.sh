#!/bin/bash

echo "🚀 Setting up Wildberries API Project..."

# Очистка
echo "🧹 Cleaning up previous containers..."
docker compose down --volumes --remove-orphans 2>/dev/null || true
docker rm -f $(docker ps -aq --filter "name=wb_") 2>/dev/null || true

# Запуск
echo "🐳 Building and starting containers..."
docker compose up --build -d

# Ожидание
echo "⏳ Waiting for database to start..."
sleep 30

# Проверка базы
echo "🔍 Testing database connection..."
if docker compose exec db mysql -u wb_user -pwb_password -e "SELECT 1;" &>/dev/null; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    echo "📋 Checking container status:"
    docker compose ps
    echo "📝 Checking logs:"
    docker compose logs db
    exit 1
fi

# Настройка приложения
echo "📦 Installing dependencies..."
docker compose exec app composer install --no-dev --optimize-autoloader

echo "⚙️ Configuring application..."
docker compose exec app cp .env.docker .env
docker compose exec app php artisan key:generate

echo "🗃️ Running migrations..."
docker compose exec app php artisan migrate

echo "🌱 Seeding database..."
docker compose exec app php artisan db:seed

echo "✅ Setup completed successfully!"
echo ""
echo "📊 Application is ready!"
echo "🔗 Test API connection: docker compose exec app php artisan test:connection"
echo "📈 Fetch data: docker compose exec app php artisan wb:fetch sales --dateFrom=2024-01-01"
