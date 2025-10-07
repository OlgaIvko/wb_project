<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Token;
use App\Models\Account;
use App\Models\ApiService;
use App\Models\TokenType;

class TokensSeeder extends Seeder
{
    public function run()
    {
        if (Token::count() === 0) {
            $account = Account::first();
            $apiService = ApiService::where('name', 'Wildberries')->first();
            $tokenType = TokenType::where('name', 'API Key')->first();

            if ($account && $apiService && $tokenType) {
                Token::create([
                    'account_id' => $account->id,
                    'api_service_id' => $apiService->id,
                    'token_type_id' => $tokenType->id,
                    'token_value' => 'E6kUTYrYwZq2tN4QEtyzsbEBk3ie',
                    'name' => 'Основной токен WB',
                    'is_active' => true,
                ]);
                $this->command->info('Tokens seeded successfully!');
            } else {
                $this->command->error('Missing dependencies for token!');
                $this->command->error('Account exists: ' . ($account ? 'Yes' : 'No'));
                $this->command->error('API Service exists: ' . ($apiService ? 'Yes' : 'No'));
                $this->command->error('Token Type exists: ' . ($tokenType ? 'Yes' : 'No'));
            }
        } else {
            $this->command->info('Tokens already exist, skipping...');
        }
    }
}
