#!/bin/bash
echo "=== ПРЯМОЕ ТЕСТИРОВАНИЕ API ==="

# Проверяем доступность данных через curl
echo "1. Тестируем sales:"
curl -s "http://109.73.206.144:6969/api/sales?dateFrom=2024-01-01&key=E6kUTYrYwZq2tN4QEtyzsbEBk3ie" | jq '.meta.total'

echo "2. Тестируем orders:"
curl -s "http://109.73.206.144:6969/api/orders?dateFrom=2024-01-01&key=E6kUTYrYwZq2tN4QEtyzsbEBk3ie" | jq '.meta.total'

echo "3. Тестируем incomes:"
curl -s "http://109.73.206.144:6969/api/incomes?dateFrom=2024-01-01&key=E6kUTYrYwZq2tN4QEtyzsbEBk3ie" | jq '.meta.total'

echo "4. Тестируем stocks:"
curl -s "http://109.73.206.144:6969/api/stocks?dateFrom=2024-10-05&key=E6kUTYrYwZq2tN4QEtyzsbEBk3ie" | jq '.meta.total'

