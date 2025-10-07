#!/bin/bash

echo "=== INSTALLING DOCKER ==="

# Обновляем пакеты
sudo apt-get update

# Устанавливаем Docker
sudo apt-get install -y docker.io

# Запускаем Docker
sudo systemctl start docker
sudo systemctl enable docker

# Добавляем пользователя в группу docker
sudo usermod -aG docker $USER

# Устанавливаем Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Docker and Docker Compose installed successfully!"
echo "Please reconnect to the server for group changes to take effect."
