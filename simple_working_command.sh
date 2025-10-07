#!/bin/bash
echo "=== СОЗДАНИЕ ПРОСТОЙ РАБОЧЕЙ КОМАНДЫ ==="

echo -e "\n1. Удаляем старые версии команды:"
docker compose exec app rm -f app/Console/Commands/FetchWildberriesData.php
docker compose exec app rm -f app/Console/Commands/WbDataFetch.php

echo -e "\n2. Создаем простейшую команду:"
docker compose exec app php artisan make:command TestWbFetch

echo -e "\n3. Заменяем содержимое команды:"
docker compose exec app bash -c "cat > app/Console/Commands/TestWbFetch.php << 'SCRIPT'
<?php

namespace App\Console\Commands;

use App\Models\Account;
use App\Models\ApiService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class TestWbFetch extends Command
{
    protected \$signature = 'wb:fetch 
                            {type : sales, orders, stocks, incomes}
                            {--dateFrom=}
                            {--dateTo=}
                            {--account=}';

    protected \$description = 'Fetch data from Wildberries API';

    public function handle()
    {
        \$this->info('WB Fetch Command is working!');
        
        \$apiService = ApiService::where('name', 'Wildberries')->first();
        if (!\$apiService) {
            \$this->error('API Service not found');
            return 1;
        }
        
        \$this->info('API Service: ' . \$apiService->base_url);
        
        \$accounts = Account::all();
        \$this->info('Accounts found: ' . \$accounts->count());
        
        foreach (\$accounts as \$account) {
            \$this->info('Account: ' . \$account->name);
            
            \$token = \$account->tokens()
                ->where('api_service_id', \$apiService->id)
                ->where('is_active', true)
                ->first();
                
            if (\$token) {
                \$this->info('Token: ' . substr(\$token->token_value, 0, 10) . '...');
                
                // Простой тест API
                \$url = \$apiService->base_url . '/api/sales';
                \$response = Http::timeout(10)->get(\$url, [
                    'dateFrom' => date('Y-m-d', strtotime('-1 day')),
                    'key' => \$token->token_value
                ]);
                
                if (\$response->successful()) {
                    \$data = \$response->json();
                    \$count = count(\$data['data'] ?? []);
                    \$this->info(\"✅ API Success: {\$count} records\");
                } else {
                    \$this->error('❌ API Error: ' . \$response->status());
                }
            } else {
                \$this->warn('No active token');
            }
        }
        
        \$this->info('Command completed successfully!');
        return 0;
    }
}
SCRIPT"

echo -e "\n4. Переименовываем класс в FetchWildberriesData:"
docker compose exec app sed -i 's/TestWbFetch/FetchWildberriesData/g' app/Console/Commands/TestWbFetch.php
docker compose exec app mv app/Console/Commands/TestWbFetch.php app/Console/Commands/FetchWildberriesData.php

echo -e "\n5. Проверяем синтаксис:"
docker compose exec app php -l app/Console/Commands/FetchWildberriesData.php

echo -e "\n6. Обновляем автозагрузку:"
docker compose exec app composer dump-autoload

echo -e "\n7. Проверяем команду:"
docker compose exec app php artisan wb:fetch sales --dateFrom=$(date -v-1d +%Y-%m-%d) --account=1

