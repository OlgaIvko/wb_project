<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WildberriesService
{
    private string $baseUrl;
    private string $token;
    private int $accountId;

    public function __construct(string $token, int $accountId)
    {
        $this->baseUrl = config('services.wildberries.base_url');
        $this->token = $token;
        $this->accountId = $accountId;
    }

    public function fetchSales(string $dateFrom, string $dateTo, int $limit = 500)
    {
        return $this->fetchData('/api/sales', $dateFrom, $dateTo, $limit);
    }

    public function fetchOrders(string $dateFrom, string $dateTo, int $limit = 500)
    {
        return $this->fetchData('/api/orders', $dateFrom, $dateTo, $limit);
    }

    public function fetchStocks(string $dateFrom, int $limit = 500)
    {
        return $this->fetchData('/api/stocks', $dateFrom, null, $limit);
    }

    public function fetchIncomes(string $dateFrom, string $dateTo, int $limit = 500)
    {
        return $this->fetchData('/api/incomes', $dateFrom, $dateTo, $limit);
    }

    private function fetchData(string $endpoint, string $dateFrom, ?string $dateTo = null, int $limit = 500)
    {
        $page = 1;
        $allData = [];
        $hasMoreData = true;

        while ($hasMoreData) {
            try {
                $params = [
                    'dateFrom' => $dateFrom,
                    'key' => $this->token,
                    'limit' => $limit,
                    'page' => $page,
                ];

                if ($dateTo) {
                    $params['dateTo'] = $dateTo;
                }

                Log::info("Fetching data from WB API", [
                    'account_id' => $this->accountId,
                    'endpoint' => $endpoint,
                    'page' => $page
                ]);

                $response = Http::retry(3, 1000, function ($exception) {
                    Log::warning("API request failed, retrying", [
                        'account_id' => $this->accountId,
                        'error' => $exception->getMessage()
                    ]);
                    return $exception instanceof \Illuminate\Http\Client\ConnectionException;
                })->timeout(60)->get($this->baseUrl . $endpoint, $params);

                if ($response->tooManyRequests()) {
                    Log::warning("Too many requests, waiting 60 seconds", [
                        'account_id' => $this->accountId,
                        'endpoint' => $endpoint
                    ]);
                    sleep(60);
                    continue;
                }

                if (!$response->successful()) {
                    Log::error("API request failed", [
                        'account_id' => $this->accountId,
                        'endpoint' => $endpoint,
                        'status' => $response->status(),
                        'response' => $response->body()
                    ]);
                    break;
                }

                $data = $response->json();

                // Проверяем структуру ответа
                if (isset($data['data'])) {
                    $data = $data['data'];
                }

                if (empty($data)) {
                    Log::info("No more data available", [
                        'account_id' => $this->accountId,
                        'endpoint' => $endpoint,
                        'page' => $page
                    ]);
                    $hasMoreData = false;
                    break;
                }

                // Обрабатываем данные
                $processedData = $this->processApiData($data);
                $recordsCount = count($processedData);

                $allData = array_merge($allData, $processedData);

                Log::info("Fetched page data", [
                    'account_id' => $this->accountId,
                    'endpoint' => $endpoint,
                    'page' => $page,
                    'records' => $recordsCount
                ]);

                // Освобождаем память
                unset($data, $processedData);

                // Проверяем, есть ли еще данные
                if ($recordsCount < $limit) {
                    $hasMoreData = false;
                } else {
                    $page++;
                }

                // Пауза между запросами
                usleep(300000);
            } catch (\Exception $e) {
                Log::error("Exception during API request", [
                    'account_id' => $this->accountId,
                    'endpoint' => $endpoint,
                    'error' => $e->getMessage()
                ]);
                $hasMoreData = false;
                break;
            }
        }

        return $allData;
    }

    private function processApiData(array $data): array
    {
        $processedData = [];

        foreach ($data as $item) {
            $processedItem = [];
            foreach ($item as $key => $value) {
                // Заменяем специальные значения на null
                if ($value === '?' || $value === '' || $value === 'null' || $value === 'NULL') {
                    $processedItem[$key] = null;
                }
                // Обрабатываем числовые значения
                elseif (is_numeric($value)) {
                    // Для больших чисел используем float чтобы избежать переполнения
                    if ($value > PHP_INT_MAX) {
                        $processedItem[$key] = (float) $value;
                    } else {
                        $processedItem[$key] = $value;
                    }
                }
                // Обрезаем длинные строки
                elseif (is_string($value) && strlen($value) > 250) {
                    $processedItem[$key] = substr($value, 0, 250);
                } else {
                    $processedItem[$key] = $value;
                }
            }
            $processedData[] = $processedItem;
        }

        return $processedData;
    }
}
