<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\TokenType;

class TokenTypesSeeder extends Seeder
{
    public function run()
    {
        $types = [
            ['name' => 'API Key', 'description' => 'Простой API ключ'],
            ['name' => 'Bearer', 'description' => 'Bearer токен'],
            ['name' => 'Basic Auth', 'description' => 'Логин и пароль'],
            ['name' => 'OAuth', 'description' => 'OAuth токен'],
        ];

        foreach ($types as $type) {
            TokenType::create($type);
        }

        $this->command->info('Token types seeded successfully!');
    }
}
