#!/bin/bash
echo "=== Базовые проверки ==="
echo "1. Проверка Docker:"
docker --version
echo ""

echo "2. Проверка контейнеров:"
docker ps
echo ""

echo "3. Проверка файлов проекта:"
echo "docker-compose.yml: $(ls docker-compose.yml 2>/dev/null && echo 'найден' || echo 'не найден')"
echo ""

echo "4. Попытка запуска контейнеров:"
docker-compose ps 2>/dev/null || docker compose ps 2>/dev/null || echo "Docker Compose не доступен"
