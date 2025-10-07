#!/bin/bash

echo "=== PUSHING PROJECT TO GIT ==="

# 1. Инициализируем Git если еще не инициализирован
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
else
    echo "Git repository already initialized"
fi

# 2. Создаем .gitignore если нет
if [ ! -f ".gitignore" ]; then
    echo "Creating .gitignore file..."
    cat > .gitignore << 'EOF'
# Laravel
/vendor/
/node_modules/
/public/hot
/public/storage
/storage/*.key
/storage/framework/cache/*
/storage/framework/sessions/*
/storage/framework/views/*
/storage/logs/*
/.env
/.env.backup
/.phpunit.result.cache
/homestead.json
/homestead.yaml
/.vagrant
/package-lock.json
/npm-debug.log*
/yarn-debug.log*
/yarn-error.log*
/.idea
/.vscode
/.nova
/Composer.lock

# Docker
.docker/
*.tar.gz

# macOS
.DS_Store

# Scripts - we keep .sh files but exclude temporary ones
*_temp.sh
*_backup.sh

# Logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity
EOF
    echo ".gitignore created"
else
    echo ".gitignore already exists"
fi

# 3. Добавляем все файлы
echo "Adding files to Git..."
git add .

# 4. Создаем коммит
echo "Creating commit..."
git commit -m "Initial commit: Wildberries API Data Fetcher

- Complete Laravel application with Docker
- Wildberries API integration for sales, orders, stocks, incomes
- Multi-account support with company/account/token management
- MySQL database on non-standard port 3307
- Scheduled data updates twice daily
- Error handling for API rate limits
- Console commands for entity management"

echo "=== READY TO PUSH ==="
echo ""
echo "Now you need to:"
echo "1. Create a repository on GitHub/GitLab"
echo "2. Add remote origin:"
echo "   git remote add origin hgit@github.com:OlgaIvko/wb_project.git"
echo "3. Push to repository:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "Or run the script below to automate these steps if you know your repo URL"
