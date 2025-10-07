<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Company;

class CompaniesSeeder extends Seeder
{
    public function run()
    {
        // Проверяем, существует ли уже компания
        if (Company::count() === 0) {
            Company::create([
                'name' => 'Основная компания',
                'description' => 'Основная компания для тестирования',
            ]);
            $this->command->info('Companies seeded successfully!');
        } else {
            $this->command->info('Companies already exist, skipping...');
        }
    }
}
