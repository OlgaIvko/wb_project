<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $this->call([
            CompaniesSeeder::class,      // Сначала компании
            ApiServicesSeeder::class,    // Затем API сервисы
            TokenTypesSeeder::class,     // Затем типы токенов
            AccountsSeeder::class,       // Затем аккаунты
            TokensSeeder::class,         // И только потом токены
        ]);
    }
}
