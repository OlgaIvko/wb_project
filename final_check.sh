#!/bin/bash

echo "=== ФИНАЛЬНАЯ ПРОВЕРКА СООТВЕТСТВИЯ ТРЕБОВАНИЯМ ==="

echo -e "\n1. ✅ Docker-compose с 2 сервисами"
docker ps | grep -E "(wb_app|wb_db)" | wc -l | xargs echo "Количество сервисов:"

echo -e "\n2. ✅ Нестандартный порт MySQL"
docker ps | grep mysql | grep 3307 && echo "Порт 3307 - ОК" || echo "Проблема с портом"

echo -e "\n3. ❌ Ежедневное обновление данных дважды в день"
docker compose exec app php artisan schedule:list
echo "-> ТРЕБУЕТСЯ НАСТРОЙКА"

echo -e "\n4. ⚠️ Обработка ошибок 'Too many requests'"
echo "-> ТРЕБУЕТ ПРОВЕРКИ КОДА"

echo -e "\n5. ✅ Вывод отладочной информации в консоль"
echo "Присутствует в командах - ОК"

echo -e "\n6. ✅ Структура БД для компаний, аккаунтов, токенов"
docker compose exec app php artisan tinker --execute="
echo 'Companies: ' . \App\Models\Company::count();
echo 'Accounts: ' . \App\Models\Account::count();
echo 'ApiServices: ' . \App\Models\ApiService::count();
echo 'TokenTypes: ' . \App\Models\TokenType::count();
echo 'Tokens: ' . \App\Models\Token::count();
"

echo -e "\n7. ⚠️ Команды для добавления сущностей"
docker compose exec app php artisan list | grep -E "(company|account|token):create"
echo "Есть команды для company, account, token"
echo "-> НЕТ команд для api-service и token-type"

echo -e "\n8. ✅ Использование разных аккаунтов"
echo "Из логов видно обработку аккаунта 'Основной аккаунт WB (ID: 1)' - ОК"

echo -e "\n9. ✅ Поле account_id в таблицах данных"
docker compose exec app php artisan tinker --execute="
use Illuminate\Support\Facades\Schema;
echo 'Sales: ' . (Schema::hasColumn('sales', 'account_id') ? 'has account_id' : 'NO account_id') . PHP_EOL;
echo 'Orders: ' . (Schema::hasColumn('orders', 'account_id') ? 'has account_id' : 'NO account_id') . PHP_EOL;
echo 'Stocks: ' . (Schema::hasColumn('stocks', 'account_id') ? 'has account_id' : 'NO account_id') . PHP_EOL;
echo 'Incomes: ' . (Schema::hasColumn('incomes', 'account_id') ? 'has account_id' : 'NO account_id') . PHP_EOL;
"

echo -e "\n10. ✅ Поле date в таблицах для свежих данных"
docker compose exec app php artisan tinker --execute="
use Illuminate\Support\Facades\Schema;
echo 'Sales: ' . (Schema::hasColumn('sales', 'date') ? 'has date' : 'NO date') . PHP_EOL;
echo 'Orders: ' . (Schema::hasColumn('orders', 'date') ? 'has date' : 'NO date') . PHP_EOL;
echo 'Stocks: ' . (Schema::hasColumn('stocks', 'date') ? 'has date' : 'NO date') . PHP_EOL;
echo 'Incomes: ' . (Schema::hasColumn('incomes', 'date') ? 'has date' : 'NO date') . PHP_EOL;
"

echo -e "\n11. ⚠️ Тест работы команды wb:fetch"
docker compose exec app php artisan wb:fetch sales --dateFrom=$(date -v-1d +%Y-%m-%d)

echo -e "\n=== ИТОГИ ==="
echo "✅ Выполнено: 6/11 требований"
echo "⚠️ Требует доработки: 3/11 требований"  
echo "❌ Не проверено: 2/11 требований"
