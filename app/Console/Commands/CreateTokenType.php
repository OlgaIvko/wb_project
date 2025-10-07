<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\TokenType;

class CreateTokenType extends Command
{
    protected $signature = 'token-type:create
                            {name : Название типа токена}
                            {description? : Описание типа токена}';

    protected $description = 'Создать новый тип токена';

    public function handle()
    {
        $tokenType = TokenType::create([
            'name' => $this->argument('name'),
            'description' => $this->argument('description') ?? '',
        ]);

        $this->info("Token Type created successfully! ID: {$tokenType->id}");

        return 0;
    }
}
