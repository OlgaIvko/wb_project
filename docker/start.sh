#!/bin/bash

echo "🚀 Starting Wildberries API Application with Docker..."

# Проверяем, установлен ли Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Проверяем, установлен ли Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Копируем .env.docker в .env если его нет
if [ ! -f .env ]; then
    if [ -f .env.docker ]; then
        cp .env.docker .env
        echo "✅ .env file created from .env.docker"
    else
        echo "❌ .env.docker file not found. Creating default .env file..."
        cat > .env << EOF
APP_NAME="Wildberries API Fetcher"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3307
DB_DATABASE=wb_sale
DB_USERNAME=wb_user
DB_PASSWORD=wb_password

WB_API_BASE_URL=http://109.73.206.144:6969
WB_API_KEY=E6kUTYrYwZq2tN4QEtyzsbEBk3ie

LOG_CHANNEL=stack
LOG_LEVEL=debug
EOF
    fi
fi

echo "🐳 Building and starting Docker containers..."
docker-compose up -d --build

echo "⏳ Waiting for services to be ready..."
sleep 30

echo "📦 Installing PHP dependencies..."
docker-compose exec app composer install --no-dev --optimize-autoloader

echo "🔑 Generating application key..."
docker-compose exec app php artisan key:generate

echo "🗄️ Running database migrations..."
docker-compose exec app php artisan migrate --force

echo "🌱 Seeding database..."
docker-compose exec app php artisan db:seed --force

echo "🔒 Setting permissions..."
docker-compose exec app chmod -R 775 storage bootstrap/cache
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache

echo "✅ Application is running!"
echo "🌐 Frontend: http://localhost:8000"
echo "🗃️ MySQL: localhost:3307 (user: wb_user, password: wb_password)"
echo "📊 To view logs: ./docker/logs.sh"
echo "🛑 To stop: ./docker/stop.sh"
