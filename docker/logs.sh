#!/bin/bash

echo "📋 Showing Docker logs..."

if [ -z "$1" ]; then
    # Если не указан сервис, показываем все логи
    docker-compose logs -f
else
    # Показываем логи конкретного сервиса
    docker-compose logs -f "$1"
fi
