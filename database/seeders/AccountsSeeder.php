<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Account;
use App\Models\Company;

class AccountsSeeder extends Seeder
{
    public function run()
    {
        // Проверяем, существует ли уже аккаунт
        if (Account::count() === 0) {
            $company = Company::first();

            if ($company) {
                Account::create([
                    'company_id' => $company->id,
                    'name' => 'Основной аккаунт WB',
                    'is_active' => true,
                ]);
                $this->command->info('Accounts seeded successfully!');
            } else {
                $this->command->error('No company found! Please run CompaniesSeeder first.');
            }
        } else {
            $this->command->info('Accounts already exist, skipping...');
        }
    }
}
