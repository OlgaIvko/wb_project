#!/bin/bash

echo "=== OPTIMIZING CODE AND REMOVING DUPLICATES ==="

# Создаем оптимизированную версию FetchWildberriesData команды
echo "1. Creating optimized FetchWildberriesData command..."
cat > app/Console/Commands/FetchWildberriesData.php << 'EOF'
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Account;
use App\Models\ApiService;
use App\Services\WildberriesService;
use Illuminate\Support\Facades\Log;

class FetchWildberriesData extends Command
{
    protected $signature = 'wb:fetch
                            {type? : Тип данных (sales, orders, stocks, incomes, all)}
                            {--dateFrom= : Дата начала в формате Y-m-d}
                            {--account= : ID аккаунта (по умолчанию все активные)}';

    protected $description = 'Загрузка данных с Wildberries API';

    public function handle()
    {
        $type = $this->argument('type') ?? 'all';
        $dateFrom = $this->option('dateFrom') ?? now()->subDays(1)->format('Y-m-d');
        $accountId = $this->option('account');

        $accounts = $this->getAccounts($accountId);
        if ($accounts->isEmpty()) {
            $this->error('No active accounts found');
            return 1;
        }

        foreach ($accounts as $account) {
            $this->processAccount($account, $type, $dateFrom);
        }

        $this->info("Data fetch completed");
        return 0;
    }

    private function getAccounts($accountId)
    {
        return $accountId
            ? Account::where('id', $accountId)->where('is_active', true)->get()
            : Account::where('is_active', true)->get();
    }

    private function processAccount(Account $account, string $type, string $dateFrom)
    {
        $this->info("Processing account: {$account->name} (ID: {$account->id})");

        $wbService = $this->getWildberriesService($account);
        if (!$wbService) {
            $this->warn("No active Wildberries token found for account: {$account->name}");
            return;
        }

        try {
            $this->fetchDataByType($wbService, $account, $type, $dateFrom);
        } catch (\Exception $e) {
            $this->error("Error processing account {$account->name}: " . $e->getMessage());
            Log::error("Error processing account", [
                'account_id' => $account->id,
                'error' => $e->getMessage()
            ]);
        }

        $this->info("Completed processing for account: {$account->name}");
    }

    private function getWildberriesService(Account $account): ?WildberriesService
    {
        $wbApiService = ApiService::where('name', 'Wildberries')->first();
        if (!$wbApiService) return null;

        $token = $account->getActiveToken($wbApiService->id);
        if (!$token) return null;

        return new WildberriesService($token->token_value, $account->id);
    }

    private function fetchDataByType($wbService, $account, string $type, string $dateFrom)
    {
        $methods = [
            'sales' => 'fetchSales',
            'orders' => 'fetchOrders',
            'stocks' => 'fetchStocks',
            'incomes' => 'fetchIncomes'
        ];

        if ($type === 'all') {
            foreach ($methods as $method) {
                $this->$method($wbService, $account, $dateFrom);
            }
        } elseif (isset($methods[$type])) {
            $method = $methods[$type];
            $this->$method($wbService, $account, $dateFrom);
        }
    }

    private function fetchSales($wbService, $account, $dateFrom)
    {
        $dateTo = now()->format('Y-m-d');
        $this->info("Fetching sales data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchSales($dateFrom, $dateTo);
        $this->processData($data, $account, 'Sale', [
            'sale_id' => 'saleID',
            'odid' => 'odid'
        ], 'sales');
    }

    private function fetchOrders($wbService, $account, $dateFrom)
    {
        $dateTo = now()->format('Y-m-d');
        $this->info("Fetching orders data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchOrders($dateFrom, $dateTo);
        $this->processData($data, $account, 'Order', [
            'odid' => 'odid'
        ], 'orders');
    }

    private function fetchStocks($wbService, $account, $dateFrom)
    {
        $this->info("Fetching stocks data for {$dateFrom}");

        $data = $wbService->fetchStocks($dateFrom);
        $this->processData($data, $account, 'Stock', [
            'nm_id' => 'nmId',
            'barcode' => 'barcode'
        ], 'stocks');
    }

    private function fetchIncomes($wbService, $account, $dateFrom)
    {
        $dateTo = now()->format('Y-m-d');
        $this->info("Fetching incomes data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchIncomes($dateFrom, $dateTo);
        $this->processData($data, $account, 'Income', [
            'income_id' => 'incomeId'
        ], 'incomes');
    }

    private function processData($data, $account, $modelClass, $uniqueKeys, $type)
    {
        $this->info("Fetched " . count($data) . " {$type} records");

        $successCount = 0;
        $errorCount = 0;
        $modelClass = "App\\Models\\{$modelClass}";

        foreach ($data as $item) {
            try {
                $uniqueAttributes = ['account_id' => $account->id];
                foreach ($uniqueKeys as $dbField => $apiField) {
                    $uniqueAttributes[$dbField] = $item[$apiField] ?? $item[$dbField] ?? null;
                }

                $modelClass::updateOrCreate($uniqueAttributes, $item);
                $successCount++;
            } catch (\Exception $e) {
                $errorCount++;
                Log::error("Error saving {$type} record", [
                    'account_id' => $account->id,
                    'error' => $e->getMessage()
                ]);
            }
        }

        $this->info(ucfirst($type) . ": {$successCount} saved, {$errorCount} errors");
    }
}
EOF

echo "2. Checking for duplicate command files..."
find app/Console/Commands -name "*.php" -type f | while read file; do
    basename=$(basename "$file")
    count=$(find app/Console/Commands -name "$basename" | wc -l)
    if [ $count -gt 1 ]; then
        echo "Found duplicate: $basename"
        # Оставляем только первый файл
        find app/Console/Commands -name "$basename" | tail -n +2 | while read duplicate; do
            echo "Removing duplicate: $duplicate"
            rm "$duplicate"
        done
    fi
done

echo "Code optimization completed!"
