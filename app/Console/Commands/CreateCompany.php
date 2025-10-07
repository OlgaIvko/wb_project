<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Company;

class CreateCompany extends Command
{
    protected $signature = 'company:create {name} {description?}';
    protected $description = 'Создать новую компанию';

    public function handle()
    {
        $company = Company::create([
            'name' => $this->argument('name'),
            'description' => $this->argument('description'),
        ]);

        $this->info("Company created successfully! ID: {$company->id}");
        return 0;
    }
}
