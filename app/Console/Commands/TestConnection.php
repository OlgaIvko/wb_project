<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;

class TestConnection extends Command
{
    protected $signature = 'test:connection';
    protected $description = 'Test database and API connections';

    public function handle()
    {
        $this->info('Testing database connection...');

        try {
            DB::connection()->getPdo();
            $this->info('✅ Database connection successful');
        } catch (\Exception $e) {
            $this->error('❌ Database connection failed: ' . $e->getMessage());
            return 1;
        }

        $this->info('Testing Wildberries API connection...');

        try {
            $response = Http::timeout(30)->get('http://109.73.206.144:6969/api/sales', [
                'key' => 'E6kUTYrYwZq2tN4QEtyzsbEBk3ie',
                'dateFrom' => date('Y-m-d', strtotime('-1 day')),
                'limit' => 1
            ]);

            if ($response->successful()) {
                $this->info('✅ Wildberries API connection successful');
                $this->info('Response status: ' . $response->status());

                $data = $response->json();
                if (isset($data['data'])) {
                    $this->info('Data structure: with wrapper');
                    $this->info('Records count: ' . count($data['data']));
                } else {
                    $this->info('Data structure: direct array');
                    $this->info('Records count: ' . count($data));
                }
            } else {
                $this->error('❌ Wildberries API request failed: ' . $response->status());
                $this->error('Response: ' . $response->body());
            }
        } catch (\Exception $e) {
            $this->error('❌ Wildberries API connection failed: ' . $e->getMessage());
            return 1;
        }

        return 0;
    }
}
