#!/bin/bash

SERVER="trainer@64.188.94.175"
PASSWORD="123456"
PROJECT_DIR="/home/trainer/wb-project"

echo "=== DEPLOYING TO SERVER ==="

# Проверяем установлен ли sshpass
if ! command -v sshpass &> /dev/null; then
    echo "ERROR: sshpass is not installed. Please install it first:"
    echo "brew install hudochenkov/sshpass/sshpass"
    echo "Or download from: https://github.com/hudochenkov/sshpass"
    exit 1
fi

# Создаем архив проекта (исключаем ненужные файлы)
echo "Creating project archive..."
tar --exclude='.git' \
    --exclude='vendor' \
    --exclude='node_modules' \
    --exclude='storage/logs/*' \
    --exclude='storage/framework/cache/*' \
    --exclude='*.tar.gz' \
    --exclude='*.sh' \
    --exclude='.DS_Store' \
    --exclude='.dockerignore' \
    --exclude='.gitignore' \
    -czf wb-project.tar.gz .

# Создаем директорию на сервере
echo "Creating project directory on server..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER "mkdir -p $PROJECT_DIR"

# Копируем архив на сервер
echo "Copying archive to server..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no wb-project.tar.gz $SERVER:$PROJECT_DIR/

# Копируем необходимые файлы отдельно
echo "Copying configuration files..."
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no docker-compose.yml $SERVER:$PROJECT_DIR/
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no .env $SERVER:$PROJECT_DIR/
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no Dockerfile $SERVER:$PROJECT_DIR/

# Распаковываем архив на сервере
echo "Extracting archive on server..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER "cd $PROJECT_DIR && tar -xzf wb-project.tar.gz && rm wb-project.tar.gz"

# Удаляем локальный архив
rm wb-project.tar.gz

echo "Deployment completed successfully!"
echo "Files have been copied to: $PROJECT_DIR on server $SERVER"
