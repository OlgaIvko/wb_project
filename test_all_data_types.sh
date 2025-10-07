#!/bin/bash
echo "=== ТЕСТИРОВАНИЕ ВСЕХ ТИПОВ ДАННЫХ ==="

echo -e "\n1. Тестируем заказы:"
docker compose exec app php artisan wb:fetch orders --dateFrom=$(date -v-1d +%Y-%m-%d) --account=1

echo -e "\n2. Тестируем остатки:"
docker compose exec app php artisan wb:fetch stocks --dateFrom=$(date +%Y-%m-%d) --account=1

echo -e "\n3. Тестируем поступления:"
docker compose exec app php artisan wb:fetch incomes --dateFrom=$(date -v-1d +%Y-%m-%d) --account=1

echo -e "\n4. Проверяем все данные в базе:"
docker compose exec app php artisan tinker --execute="
echo '=== ВСЕ ДАННЫЕ В БАЗЕ ===';
echo 'Продажи: ' . \App\Models\Sale::count();
echo 'Заказы: ' . \App\Models\Order::count();
echo 'Остатки: ' . \App\Models\Stock::count();
echo 'Поступления: ' . \App\Models\Income::count();

echo '=== ДАННЫЕ ПО АККАУНТАМ ===';
foreach (\App\Models\Account::all() as \$account) {
    echo 'Аккаунт ' . \$account->name . ':';
    echo '  Продажи: ' . \App\Models\Sale::where('account_id', \$account->id)->count();
    echo '  Заказы: ' . \App\Models\Order::where('account_id', \$account->id)->count();
    echo '  Остатки: ' . \App\Models\Stock::where('account_id', \$account->id)->count();
    echo '  Поступления: ' . \App\Models\Income::where('account_id', \$account->id)->count();
}
"

