#!/bin/bash

echo "=== FIXING SALES DATA LOADING ISSUE ==="

# Проверим структуру таблицы sales и пример данных
echo "1. Checking sales table structure and sample data..."
docker compose exec db mysql -u wb_user -pwb_password wb_sale -e "
DESCRIBE sales;
SELECT 'Sample sales data:' as '';
SELECT * FROM sales LIMIT 2;
"

# Проверим логи ошибок
echo ""
echo "2. Checking recent error logs..."
docker compose exec app tail -n 20 storage/logs/laravel.log | grep -i error || echo "No recent errors found in log"

# Создаем исправленную версию метода для sales
echo ""
echo "3. Creating fixed sales loading method..."
cat > app/Console/Commands/FixSalesLoading.php << 'EOF'
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Account;
use App\Models\ApiService;
use App\Services\WildberriesService;

class FixSalesLoading extends Command
{
    protected $signature = 'fix:sales-loading {--account=1} {--dateFrom=2025-10-01}';
    protected $description = 'Fix sales data loading issues';

    public function handle()
    {
        $account = Account::find($this->option('account'));
        if (!$account) {
            $this->error('Account not found');
            return 1;
        }

        $wbService = $this->getWildberriesService($account);
        if (!$wbService) {
            $this->error('Wildberries service not found');
            return 1;
        }

        $dateFrom = $this->option('dateFrom');
        $dateTo = now()->format('Y-m-d');

        $this->info("Fetching sales data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchSales($dateFrom, $dateTo);
        $this->info("Fetched " . count($data) . " sales records");

        $successCount = 0;
        $errorCount = 0;

        foreach ($data as $sale) {
            try {
                $this->saveSaleRecord($sale, $account->id);
                $successCount++;
            } catch (\Exception $e) {
                $errorCount++;
                if ($errorCount <= 5) { // Покажем только первые 5 ошибок
                    $this->warn("Error saving sales record: " . $e->getMessage());
                }
            }
        }

        $this->info("Sales loading result: {$successCount} saved, {$errorCount} errors");
        return 0;
    }

    private function getWildberriesService(Account $account): ?WildberriesService
    {
        $wbApiService = ApiService::where('name', 'Wildberries')->first();
        if (!$wbApiService) return null;

        $token = $account->getActiveToken($wbApiService->id);
        if (!$token) return null;

        return new WildberriesService($token->token_value, $account->id);
    }

    private function saveSaleRecord(array $sale, int $accountId)
    {
        // Подготовка данных с проверкой на null и преобразованием типов
        $saleData = [
            'account_id' => $accountId,
            'date' => $sale['date'] ?? null,
            'last_change_date' => $sale['lastChangeDate'] ?? $sale['last_change_date'] ?? null,
            'supplier_article' => $sale['supplierArticle'] ?? $sale['supplier_article'] ?? null,
            'tech_size' => $sale['techSize'] ?? $sale['tech_size'] ?? null,
            'barcode' => $sale['barcode'] ?? null,
            'total_price' => $this->parseFloat($sale['totalPrice'] ?? $sale['total_price'] ?? 0),
            'discount_percent' => $this->parseFloat($sale['discountPercent'] ?? $sale['discount_percent'] ?? 0),
            'warehouse_name' => $sale['warehouseName'] ?? $sale['warehouse_name'] ?? null,
            'country_name' => $sale['countryName'] ?? $sale['country_name'] ?? null,
            'oblast_okrug_name' => $sale['oblastOkrugName'] ?? $sale['oblast_okrug_name'] ?? null,
            'region_name' => $sale['regionName'] ?? $sale['region_name'] ?? null,
            'income_id' => $sale['incomeID'] ?? $sale['income_id'] ?? null,
            'sale_id' => $sale['saleID'] ?? $sale['sale_id'] ?? null,
            'odid' => $sale['odid'] ?? null,
            'spp' => $this->parseFloat($sale['spp'] ?? 0),
            'for_pay' => $this->parseFloat($sale['forPay'] ?? $sale['for_pay'] ?? 0),
            'finished_price' => $this->parseFloat($sale['finishedPrice'] ?? $sale['finished_price'] ?? 0),
            'price_with_disc' => $this->parseFloat($sale['priceWithDisc'] ?? $sale['price_with_disc'] ?? 0),
            'nm_id' => $sale['nmId'] ?? $sale['nm_id'] ?? null,
            'subject' => $sale['subject'] ?? null,
            'category' => $sale['category'] ?? null,
            'brand' => $sale['brand'] ?? null,
            'is_storno' => $this->parseBool($sale['isStorno'] ?? $sale['is_storno'] ?? false),
        ];

        // Уникальные ключи для предотвращения дубликатов
        $uniqueKeys = [
            'account_id' => $accountId,
            'sale_id' => $saleData['sale_id'],
            'odid' => $saleData['odid'],
        ];

        \App\Models\Sale::updateOrCreate($uniqueKeys, $saleData);
    }

    private function parseFloat($value): float
    {
        if (is_null($value) || $value === '') return 0.0;
        return (float) $value;
    }

    private function parseBool($value): bool
    {
        if (is_bool($value)) return $value;
        if (is_numeric($value)) return (bool) $value;
        if (is_string($value)) {
            $value = strtolower($value);
            return in_array($value, ['true', '1', 'yes', 'on']);
        }
        return false;
    }
}
EOF

echo "4. Running the fix..."
docker compose exec app php artisan fix:sales-loading --account=1 --dateFrom=2025-10-01

echo "Sales loading fix completed!"
