<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ApiService;

class ApiServicesSeeder extends Seeder
{
    public function run()
    {
        $services = [
            [
                'name' => 'Wildberries',
                'base_url' => 'http://109.73.206.144:6969',
                'supported_token_types' => [1], // API Key
            ],
        ];

        foreach ($services as $service) {
            ApiService::create($service);
        }
    }
}
