<?php
// app/Console/Commands/FetchWildberriesData.php

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

        // Определяем аккаунты для обработки
        $accounts = $accountId
            ? Account::where('id', $accountId)->where('is_active', true)->get()
            : Account::where('is_active', true)->get();

        if ($accounts->isEmpty()) {
            $this->error('No active accounts found');
            return 1;
        }

        foreach ($accounts as $account) {
            $this->info("Processing account: {$account->name} (ID: {$account->id})");

            // Получаем токен для Wildberries API
            $wbService = $this->getWildberriesService($account);
            if (!$wbService) {
                $this->warn("No active Wildberries token found for account: {$account->name}");
                continue;
            }

            try {
                switch ($type) {
                    case 'sales':
                    case 'all':
                        $this->fetchSales($wbService, $account, $dateFrom);
                        break;

                    case 'orders':
                    case 'all':
                        $this->fetchOrders($wbService, $account, $dateFrom);
                        break;

                    case 'stocks':
                    case 'all':
                        $this->fetchStocks($wbService, $account, $dateFrom);
                        break;

                    case 'incomes':
                    case 'all':
                        $this->fetchIncomes($wbService, $account, $dateFrom);
                        break;
                }
            } catch (\Exception $e) {
                $this->error("Error processing account {$account->name}: " . $e->getMessage());
                Log::error("Error processing account", [
                    'account_id' => $account->id,
                    'error' => $e->getMessage()
                ]);
            }

            $this->info("Completed processing for account: {$account->name}");
        }

        $this->info("Data fetch completed");
        return 0;
    }

    private function getWildberriesService(Account $account): ?WildberriesService
    {
        $wbApiService = ApiService::where('name', 'Wildberries')->first();
        if (!$wbApiService) {
            return null;
        }

        $token = $account->getActiveToken($wbApiService->id);
        if (!$token) {
            return null;
        }

        return new WildberriesService($token->token_value, $account->id);
    }

    private function fetchSales($wbService, $account, $dateFrom)
    {
        $dateTo = now()->format('Y-m-d');
        $this->info("Fetching sales data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchSales($dateFrom, $dateTo);
        $this->info("Fetched " . count($data) . " sales records");

        $successCount = 0;
        $errorCount = 0;

        foreach ($data as $sale) {
            try {
                \App\Models\Sale::updateOrCreate(
                    [
                        'account_id' => $account->id,
                        'sale_id' => $sale['saleID'] ?? $sale['sale_id'] ?? null,
                        'odid' => $sale['odid'] ?? null,
                    ],
                    [
                        'date' => $sale['date'] ?? null,
                        'last_change_date' => $sale['lastChangeDate'] ?? $sale['last_change_date'] ?? null,
                        'supplier_article' => $sale['supplierArticle'] ?? $sale['supplier_article'] ?? null,
                        'tech_size' => $sale['techSize'] ?? $sale['tech_size'] ?? null,
                        'barcode' => $sale['barcode'] ?? null,
                        'total_price' => $sale['totalPrice'] ?? $sale['total_price'] ?? 0,
                        'discount_percent' => $sale['discountPercent'] ?? $sale['discount_percent'] ?? 0,
                        'warehouse_name' => $sale['warehouseName'] ?? $sale['warehouse_name'] ?? null,
                        'country_name' => $sale['countryName'] ?? $sale['country_name'] ?? null,
                        'oblast_okrug_name' => $sale['oblastOkrugName'] ?? $sale['oblast_okrug_name'] ?? null,
                        'region_name' => $sale['regionName'] ?? $sale['region_name'] ?? null,
                        'income_id' => $sale['incomeID'] ?? $sale['income_id'] ?? null,
                        'spp' => $sale['spp'] ?? 0,
                        'for_pay' => $sale['forPay'] ?? $sale['for_pay'] ?? 0,
                        'finished_price' => $sale['finishedPrice'] ?? $sale['finished_price'] ?? 0,
                        'price_with_disc' => $sale['priceWithDisc'] ?? $sale['price_with_disc'] ?? 0,
                        'nm_id' => $sale['nmId'] ?? $sale['nm_id'] ?? null,
                        'subject' => $sale['subject'] ?? null,
                        'category' => $sale['category'] ?? null,
                        'brand' => $sale['brand'] ?? null,
                        'is_storno' => $sale['isStorno'] ?? $sale['is_storno'] ?? false,
                    ]
                );
                $successCount++;
            } catch (\Exception $e) {
                $errorCount++;
                Log::error("Error saving sales record", [
                    'account_id' => $account->id,
                    'error' => $e->getMessage()
                ]);
            }
        }

        $this->info("Sales: {$successCount} saved, {$errorCount} errors");
    }

    private function fetchOrders($wbService, $account, $dateFrom)
    {
        $dateTo = now()->format('Y-m-d');
        $this->info("Fetching orders data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchOrders($dateFrom, $dateTo);
        $this->info("Fetched " . count($data) . " orders records");

        $successCount = 0;
        $errorCount = 0;

        foreach ($data as $order) {
            try {
                \App\Models\Order::updateOrCreate(
                    [
                        'account_id' => $account->id,
                        'odid' => $order['odid'] ?? null,
                        'g_number' => $order['gNumber'] ?? $order['g_number'] ?? null,
                    ],
                    [
                        'date' => $order['date'] ?? null,
                        'last_change_date' => $order['lastChangeDate'] ?? $order['last_change_date'] ?? null,
                        'supplier_article' => $order['supplierArticle'] ?? $order['supplier_article'] ?? null,
                        'tech_size' => $order['techSize'] ?? $order['tech_size'] ?? null,
                        'barcode' => $order['barcode'] ?? null,
                        'total_price' => $order['totalPrice'] ?? $order['total_price'] ?? 0,
                        'discount_percent' => $order['discountPercent'] ?? $order['discount_percent'] ?? 0,
                        'warehouse_name' => $order['warehouseName'] ?? $order['warehouse_name'] ?? null,
                        'oblast' => $order['oblast'] ?? null,
                        'income_id' => $order['incomeID'] ?? $order['income_id'] ?? null,
                        'nm_id' => $order['nmId'] ?? $order['nm_id'] ?? null,
                        'subject' => $order['subject'] ?? null,
                        'category' => $order['category'] ?? null,
                        'brand' => $order['brand'] ?? null,
                        'is_cancel' => $order['isCancel'] ?? $order['is_cancel'] ?? false,
                        'cancel_dt' => $order['cancel_dt'] ?? null,
                        'sticker' => $order['sticker'] ?? null,
                    ]
                );
                $successCount++;
            } catch (\Exception $e) {
                $errorCount++;
                Log::error("Error saving orders record", [
                    'account_id' => $account->id,
                    'error' => $e->getMessage()
                ]);
            }
        }

        $this->info("Orders: {$successCount} saved, {$errorCount} errors");
    }

    private function fetchStocks($wbService, $account, $dateFrom)
    {
        $this->info("Fetching stocks data for {$dateFrom}");

        $data = $wbService->fetchStocks($dateFrom);
        $this->info("Fetched " . count($data) . " stocks records");

        $successCount = 0;
        $errorCount = 0;

        foreach ($data as $stock) {
            try {
                \App\Models\Stock::updateOrCreate(
                    [
                        'account_id' => $account->id,
                        'nm_id' => $stock['nmId'] ?? $stock['nm_id'] ?? null,
                        'barcode' => $stock['barcode'] ?? null,
                        'warehouse_name' => $stock['warehouseName'] ?? $stock['warehouse_name'] ?? null,
                    ],
                    [
                        'date' => $stock['date'] ?? null,
                        'last_change_date' => $stock['lastChangeDate'] ?? $stock['last_change_date'] ?? null,
                        'supplier_article' => $stock['supplierArticle'] ?? $stock['supplier_article'] ?? null,
                        'tech_size' => $stock['techSize'] ?? $stock['tech_size'] ?? null,
                        'quantity' => $stock['quantity'] ?? 0,
                        'quantity_full' => $stock['quantityFull'] ?? $stock['quantity_full'] ?? 0,
                        'quantity_not_in_orders' => $stock['quantityNotInOrders'] ?? $stock['quantity_not_in_orders'] ?? 0,
                        'subject' => $stock['subject'] ?? null,
                        'category' => $stock['category'] ?? null,
                        'brand' => $stock['brand'] ?? null,
                        'in_way_to_client' => $stock['inWayToClient'] ?? $stock['in_way_to_client'] ?? 0,
                        'in_way_from_client' => $stock['inWayFromClient'] ?? $stock['in_way_from_client'] ?? 0,
                    ]
                );
                $successCount++;
            } catch (\Exception $e) {
                $errorCount++;
                Log::error("Error saving stocks record", [
                    'account_id' => $account->id,
                    'error' => $e->getMessage()
                ]);
            }
        }

        $this->info("Stocks: {$successCount} saved, {$errorCount} errors");
    }

    private function fetchIncomes($wbService, $account, $dateFrom)
    {
        $dateTo = now()->format('Y-m-d');
        $this->info("Fetching incomes data from {$dateFrom} to {$dateTo}");

        $data = $wbService->fetchIncomes($dateFrom, $dateTo);
        $this->info("Fetched " . count($data) . " incomes records");

        $successCount = 0;
        $errorCount = 0;

        foreach ($data as $income) {
            try {
                \App\Models\Income::updateOrCreate(
                    [
                        'account_id' => $account->id,
                        'income_id' => $income['incomeId'] ?? $income['income_id'] ?? null,
                        'nm_id' => $income['nmId'] ?? $income['nm_id'] ?? null,
                    ],
                    [
                        'date' => $income['date'] ?? null,
                        'last_change_date' => $income['lastChangeDate'] ?? $income['last_change_date'] ?? null,
                        'supplier_article' => $income['supplierArticle'] ?? $income['supplier_article'] ?? null,
                        'tech_size' => $income['techSize'] ?? $income['tech_size'] ?? null,
                        'barcode' => $income['barcode'] ?? null,
                        'quantity' => $income['quantity'] ?? 0,
                        'total_price' => $income['totalPrice'] ?? $income['total_price'] ?? 0,
                        'date_close' => $income['dateClose'] ?? $income['date_close'] ?? null,
                        'warehouse_name' => $income['warehouseName'] ?? $income['warehouse_name'] ?? null,
                        'status' => $income['status'] ?? null,
                    ]
                );
                $successCount++;
            } catch (\Exception $e) {
                $errorCount++;
                Log::error("Error saving incomes record", [
                    'account_id' => $account->id,
                    'error' => $e->getMessage()
                ]);
            }
        }

        $this->info("Incomes: {$successCount} saved, {$errorCount} errors");
    }
}
