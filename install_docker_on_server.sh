#!/bin/bash

SERVER="trainer@64.188.94.175"
PASSWORD="123456"

echo "=== INSTALLING DOCKER ON SERVER ==="

# Копируем скрипт установки на сервер
sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no install_docker.sh $SERVER:/home/trainer/

# Запускаем установку Docker на сервере
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER "chmod +x /home/trainer/install_docker.sh && /home/trainer/install_docker.sh"

echo "Docker installation completed on server!"
echo "Please reconnect to the server for group changes to take effect."
