#!/bin/bash

echo "=== FIXING DUPLICATES AND ADDING UNIQUE KEYS ==="

# Создаем миграцию для очистки дубликатов и добавления уникальных ключей
cat > database/migrations/$(date +%Y_%m_%d_%H%M%S)_fix_duplicates_and_unique_keys.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Очищаем дубликаты в token_types, оставляя только первые записи
        DB::statement('
            DELETE t1 FROM token_types t1
            INNER JOIN token_types t2
            WHERE t1.id > t2.id AND t1.name = t2.name
        ');

        // Очищаем дубликаты в api_services, оставляя только первые записи
        DB::statement('
            DELETE t1 FROM api_services t1
            INNER JOIN api_services t2
            WHERE t1.id > t2.id AND t1.name = t2.name
        ');

        // Добавляем уникальные индексы
        Schema::table('token_types', function (Blueprint $table) {
            $table->unique('name');
        });

        Schema::table('api_services', function (Blueprint $table) {
            $table->unique('name');
        });

        // Добавляем составной уникальный индекс для tokens
        Schema::table('tokens', function (Blueprint $table) {
            $table->unique(['account_id', 'api_service_id']);
        });
    }

    public function down()
    {
        Schema::table('token_types', function (Blueprint $table) {
            $table->dropUnique(['name']);
        });

        Schema::table('api_services', function (Blueprint $table) {
            $table->dropUnique(['name']);
        });

        Schema::table('tokens', function (Blueprint $table) {
            $table->dropUnique(['account_id', 'api_service_id']);
        });
    }
};
EOF

echo "Running migrations..."
docker compose exec app php artisan migrate

echo "Checking results after fixes..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
SELECT 'Token types after cleanup:' as '';
SELECT * FROM token_types;

SELECT 'API services after cleanup:' as '';
SELECT * FROM api_services;

SELECT 'Unique indexes:' as '';
SHOW INDEX FROM token_types WHERE Non_unique = 0;
SHOW INDEX FROM api_services WHERE Non_unique = 0;
SHOW INDEX FROM tokens WHERE Non_unique = 0;
"

echo "Duplicates cleaned and unique keys added!"
EOF
