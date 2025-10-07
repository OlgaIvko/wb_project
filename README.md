# Wildberries API Data Fetcher

Подключение к серверу:

-   Хост: 109.73.206.144:6969
-   Ключ: E6kUTYrYwZq2tN4QEtyzsbEBk3ie

База данных:

-   XAMPP MySQL
-   База: wb_sale
-   Хост: 127.0.0.1
-   Порт: 3306
-   Пользователь: root
-   Пароль: (пустой)

## Быстрый старт:

1. Настройте базу данных wb_sale в XAMPP
2. Скопируйте файлы проекта в htdocs
3. Настройте .env файл
4. Выполните команды:

```bash
composer install
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan test:connection
```
