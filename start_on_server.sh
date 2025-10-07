#!/bin/bash

PROJECT_DIR="/home/trainer/wb-project"

echo "=== STARTING PROJECT ON SERVER ==="

cd $PROJECT_DIR

# Останавливаем существующие контейнеры
docker-compose down

# Запускаем проект
docker-compose up -d

echo "Project started successfully!"
echo "MySQL is running on port 3307"
echo "Check containers: docker-compose ps"
echo "View logs: docker-compose logs -f"
