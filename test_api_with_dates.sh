#!/bin/bash
echo "=== ТЕСТИРОВАНИЕ API С РАЗНЫМИ ДАТАМИ ==="

echo -e "\n1. Проверяем доступные данные за последние дни:"
docker compose exec app php artisan tinker --execute="
use Illuminate\Support\Facades\Http;

\$url = 'http://109.73.206.144:6969/api/sales';
\$token = 'E6kUTYrYwZq2tN4QEtyzsbEBk3ie';

\$dates = ['2024-10-01', '2024-09-01', '2024-08-01', '2024-07-01'];

foreach (\$dates as \$date) {
    echo 'Проверяем дату: ' . \$date . PHP_EOL;
    
    try {
        \$response = Http::timeout(30)->get(\$url, [
            'dateFrom' => \$date,
            'key' => \$token
        ]);
        
        \$data = \$response->json();
        echo '  Status: ' . \$response->status() . PHP_EOL;
        echo '  Total records: ' . (\$data['meta']['total'] ?? 'N/A') . PHP_EOL;
        echo '  Data count: ' . count(\$data['data'] ?? []) . PHP_EOL;
        
        if (count(\$data['data'] ?? []) > 0) {
            echo '  ✅ Есть данные!' . PHP_EOL;
            break;
        }
        
    } catch (Exception \$e) {
        echo '  Error: ' . \$e->getMessage() . PHP_EOL;
    }
    echo '---' . PHP_EOL;
}
"

echo -e "\n2. Проверяем другие эндпоинты:"
docker compose exec app php artisan tinker --execute="
use Illuminate\Support\Facades\Http;

\$token = 'E6kUTYrYwZq2tN4QEtyzsbEBk3ie';
\$base_url = 'http://109.73.206.144:6969/api/';
\$endpoints = ['orders', 'incomes', 'stocks'];

foreach (\$endpoints as \$endpoint) {
    echo 'Проверяем эндпоинт: ' . \$endpoint . PHP_EOL;
    
    try {
        \$response = Http::timeout(30)->get(\$base_url . \$endpoint, [
            'dateFrom' => '2024-09-01',
            'key' => \$token
        ]);
        
        \$data = \$response->json();
        echo '  Status: ' . \$response->status() . PHP_EOL;
        echo '  Total records: ' . (\$data['meta']['total'] ?? 'N/A') . PHP_EOL;
        echo '  Data count: ' . count(\$data['data'] ?? []) . PHP_EOL;
        
    } catch (Exception \$e) {
        echo '  Error: ' . \$e->getMessage() . PHP_EOL;
    }
    echo '---' . PHP_EOL;
}
"

