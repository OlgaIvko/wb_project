<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\ApiService;

class CreateApiService extends Command
{
    protected $signature = 'api-service:create
                            {name : Название API сервиса}
                            {base_url : Базовый URL}
                            {supported_token_types : Поддерживаемые типы токенов (через запятую)}';

    protected $description = 'Создать новый API сервис';

    public function handle()
    {
        $tokenTypes = array_map('trim', explode(',', $this->argument('supported_token_types')));

        $apiService = ApiService::create([
            'name' => $this->argument('name'),
            'base_url' => $this->argument('base_url'),
            'supported_token_types' => $tokenTypes,
        ]);

        $this->info("API Service created successfully! ID: {$apiService->id}");
        $this->info("Supported token types: " . implode(', ', $tokenTypes));

        return 0;
    }
}
