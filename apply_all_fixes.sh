#!/bin/bash

echo "=== APPLYING ALL CRITICAL FIXES ==="

# 1. Останавливаем контейнеры
echo "Stopping containers..."
docker compose down

# 2. Обновляем docker-compose.yml с правильными портами
echo "Updating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    build: .
    container_name: wb_app
    working_dir: /var/www
    environment:
      - DB_HOST=db
      - DB_PORT=3307
      - DB_DATABASE=wb_sale
      - DB_USERNAME=wb_user
      - DB_PASSWORD=wb_password
    depends_on:
      - db
    volumes:
      - .:/var/www
    command: sleep infinity

  db:
    image: mysql:8.0
    container_name: wb_db
    environment:
      MYSQL_DATABASE: wb_sale
      MYSQL_USER: wb_user
      MYSQL_PASSWORD: wb_password
      MYSQL_ROOT_PASSWORD: root_password
    ports:
      - "3307:3307"
    volumes:
      - db_data:/var/lib/mysql
    command: >
      --port=3307
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --default-authentication-plugin=mysql_native_password

volumes:
  db_data:
EOF

# 3. Создаем недостающие команды
echo "Creating missing commands..."

# CreateApiService.php
cat > app/Console/Commands/CreateApiService.php << 'EOF'
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\ApiService;

class CreateApiService extends Command
{
    protected $signature = 'api-service:create
                            {name : Название API сервиса}
                            {base_url : Базовый URL}
                            {supported_token_types : Поддерживаемые типы токенов (через запятую)}';

    protected $description = 'Создать новый API сервис';

    public function handle()
    {
        $tokenTypes = array_map('trim', explode(',', $this->argument('supported_token_types')));

        $apiService = ApiService::create([
            'name' => $this->argument('name'),
            'base_url' => $this->argument('base_url'),
            'supported_token_types' => $tokenTypes,
        ]);

        $this->info("API Service created successfully! ID: {$apiService->id}");
        $this->info("Supported token types: " . implode(', ', $tokenTypes));

        return 0;
    }
}
EOF

# CreateTokenType.php
cat > app/Console/Commands/CreateTokenType.php << 'EOF'
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\TokenType;

class CreateTokenType extends Command
{
    protected $signature = 'token-type:create
                            {name : Название типа токена}
                            {description? : Описание типа токена}';

    protected $description = 'Создать новый тип токена';

    public function handle()
    {
        $tokenType = TokenType::create([
            'name' => $this->argument('name'),
            'description' => $this->argument('description') ?? '',
        ]);

        $this->info("Token Type created successfully! ID: {$tokenType->id}");

        return 0;
    }
}
EOF

# 4. Запускаем контейнеры
echo "Starting containers..."
docker compose up -d

# 5. Ждем запуска MySQL
echo "Waiting for MySQL to start..."
sleep 30

# 6. Проверяем доступность команд
echo "Testing commands..."
docker compose exec app php artisan list | grep -E "(api-service|token-type)"

echo "=== ALL FIXES APPLIED SUCCESSFULLY ==="
echo "You can now run: docker compose exec app php artisan list"
