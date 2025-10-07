<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Account;
use App\Models\Company;

class CreateAccount extends Command
{
    protected $signature = 'account:create {company_id} {name}';
    protected $description = 'Создать новый аккаунт для компании';

    public function handle()
    {
        $company = Company::find($this->argument('company_id'));

        if (!$company) {
            $this->error('Company not found');
            return 1;
        }

        $account = Account::create([
            'company_id' => $company->id,
            'name' => $this->argument('name'),
        ]);

        $this->info("Account created successfully! ID: {$account->id}");
        return 0;
    }
}
