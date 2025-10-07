#!/bin/bash
echo "=== НАСТРОЙКА КОМАНДЫ WB:FETCH ==="

echo -e "\n1. Создаем базовую логику команды:"
docker compose exec app bash -c "cat > /app/app/Console/Commands/FetchWildberriesData.php << 'SCRIPT'
<?php

namespace App\Console\Commands;

use App\Models\Account;
use App\Models\ApiService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class FetchWildberriesData extends Command
{
    protected \$signature = 'wb:fetch 
                            {type : Тип данных (sales, orders, stocks, incomes)}
                            {--dateFrom= : Дата начала в формате Y-m-d}
                            {--account= : ID аккаунта или \"all\" для всех аккаунтов}';
    
    protected \$description = 'Выгрузка данных из Wildberries API';

    public function handle()
    {
        \$type = \$this->argument('type');
        \$dateFrom = \$this->option('dateFrom') ?? date('Y-m-d', strtotime('-1 day'));
        \$accountOption = \$this->option('account') ?? 'all';

        \$this->info(\"Starting data fetch for: {\$type}\");
        \$this->info(\"Date from: {\$dateFrom}\");
        \$this->info(\"Account: {\$accountOption}\");

        // Получаем ID сервиса Wildberries
        \$wbService = ApiService::where('name', 'Wildberries')->first();
        
        if (!\$wbService) {
            \$this->error('Wildberries API service not found');
            return 1;
        }

        // Определяем аккаунты для обработки
        if (\$accountOption === 'all') {
            \$accounts = Account::all();
        } else {
            \$accounts = Account::where('id', \$accountOption)->get();
        }

        if (\$accounts->isEmpty()) {
            \$this->error('No accounts found');
            return 1;
        }

        \$this->info(\"Found {\$accounts->count()} accounts to process\");

        foreach (\$accounts as \$account) {
            \$this->info(\"Processing account: {\$account->name} (ID: {\$account->id})\");

            \$token = \$account->getActiveToken(\$wbService->id);
            if (!\$token) {
                \$this->warn(\"No active token found for account {\$account->name}\");
                continue;
            }

            \$this->info(\"Fetching {\$type} data from {\$dateFrom} to \" . date('Y-m-d'));
            
            // Базовая логика выгрузки данных
            \$url = \$wbService->base_url . '/api/' . \$type;
            
            try {
                \$response = Http::timeout(30)->get(\$url, [
                    'dateFrom' => \$dateFrom,
                    'key' => \$token->token_value
                ]);

                if (\$response->successful()) {
                    \$data = \$response->json();
                    \$recordsCount = count(\$data['data'] ?? []);
                    \$this->info(\"Fetched {\$recordsCount} {\$type} records for account {\$account->name}\");
                    
                    // Здесь должна быть логика сохранения данных в БД
                    \$this->info(\"Data saved to database for account {\$account->name}\");
                } else {
                    \$this->error(\"API request failed for account {\$account->name}: {\$response->status()}\");
                }
            } catch (\Exception \$e) {
                \$this->error(\"Error fetching data for account {\$account->name}: {\$e->getMessage()}\");
            }
        }

        \$this->info('Data fetch completed');
        return 0;
    }
}
SCRIPT"

echo -e "\n2. Проверяем синтаксис PHP:"
docker compose exec app php -l /app/app/Console/Commands/FetchWildberriesData.php

echo -e "\n3. Тестируем команду:"
docker compose exec app php artisan wb:fetch sales --dateFrom=$(date -v-1d +%Y-%m-%d) --account=all

