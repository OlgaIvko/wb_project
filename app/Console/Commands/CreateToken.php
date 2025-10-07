<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Token;
use App\Models\Account;
use App\Models\ApiService;
use App\Models\TokenType;

class CreateToken extends Command
{
    protected $signature = 'token:create
                            {account_id : ID аккаунта}
                            {api_service_id : ID API сервиса}
                            {token_type_id : ID типа токена}
                            {token_value : Значение токена}
                            {name? : Название токена}';

    protected $description = 'Создать новый токен для аккаунта';

    public function handle()
    {
        $account = Account::find($this->argument('account_id'));
        $apiService = ApiService::find($this->argument('api_service_id'));
        $tokenType = TokenType::find($this->argument('token_type_id'));

        if (!$account) {
            $this->error('Account not found');
            return 1;
        }

        if (!$apiService) {
            $this->error('API Service not found');
            return 1;
        }

        if (!$tokenType) {
            $this->error('Token Type not found');
            return 1;
        }

        // Проверяем поддерживает ли сервис данный тип токена
        if (!in_array($tokenType->id, $apiService->supported_token_types)) {
            $this->error("This API service doesn't support the specified token type");
            $this->error("Supported types: " . implode(', ', $apiService->supported_token_types));
            return 1;
        }

        $token = Token::create([
            'account_id' => $account->id,
            'api_service_id' => $apiService->id,
            'token_type_id' => $tokenType->id,
            'token_value' => $this->argument('token_value'),
            'name' => $this->argument('name'),
        ]);

        $this->info("Token created successfully! ID: {$token->id}");
        return 0;
    }
}
