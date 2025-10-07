#!/bin/bash

echo "=== COMPLETE FIX AND INITIALIZATION ==="

# 1. Останавливаем и удаляем старые контейнеры
echo "Cleaning up old containers..."
docker compose down

# 2. Обновляем docker-compose.yml (убираем version)
echo "Updating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
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
mkdir -p app/Console/Commands

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

# 6. Проверяем подключение к БД
echo "Testing database connection..."
docker compose exec app php artisan tinker --execute="echo 'DB connected: ' . (DB::connection()->getPdo() ? 'Yes' : 'No') . PHP_EOL;"

# 7. Создаем недостающие типы токенов (только если их нет)
echo "Creating missing token types..."
docker compose exec app php artisan tinker --execute="
if (!\App\Models\TokenType::where('name', 'api-key')->exists()) {
    \App\Models\TokenType::create(['name' => 'api-key', 'description' => 'API Key authentication']);
    echo 'Created api-key token type' . PHP_EOL;
}
if (!\App\Models\TokenType::where('name', 'bearer')->exists()) {
    \App\Models\TokenType::create(['name' => 'bearer', 'description' => 'Bearer token authentication']);
    echo 'Created bearer token type' . PHP_EOL;
}
if (!\App\Models\TokenType::where('name', 'basic-auth')->exists()) {
    \App\Models\TokenType::create(['name' => 'basic-auth', 'description' => 'Basic authentication']);
    echo 'Created basic-auth token type' . PHP_EOL;
}
if (!\App\Models\TokenType::where('name', 'oauth')->exists()) {
    \App\Models\TokenType::create(['name' => 'oauth', 'description' => 'OAuth authentication']);
    echo 'Created oauth token type' . PHP_EOL;
}
"

# 8. Создаем Wildberries API сервис (только если его нет)
echo "Creating Wildberries API service..."
docker compose exec app php artisan tinker --execute="
if (!\App\Models\ApiService::where('name', 'Wildberries')->exists()) {
    \App\Models\ApiService::create([
        'name' => 'Wildberries',
        'base_url' => 'http://109.73.206.144:6969',
        'supported_token_types' => [1] // api-key
    ]);
    echo 'Created Wildberries API service' . PHP_EOL;
}
"

# 9. Проверяем, что команды работают
echo "Testing commands..."
docker compose exec app php artisan api-service:create --help
docker compose exec app php artisan token-type:create --help

echo "=== COMPLETE FIX AND INITIALIZATION FINISHED ==="
echo "Containers are running on port 3307"
echo "You can test with: docker compose exec app php artisan wb:fetch stocks --dateFrom=2025-10-06"
