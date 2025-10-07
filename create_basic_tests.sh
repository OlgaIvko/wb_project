#!/bin/bash

echo "=== CREATING BASIC TESTS ==="

# Создаем директорию для тестов если нет
mkdir -p tests/Unit tests/Feature

# Тест для модели Company
cat > tests/Unit/CompanyTest.php << 'EOF'
<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Company;

class CompanyTest extends TestCase
{
    /** @test */
    public function it_can_create_a_company()
    {
        $company = Company::create([
            'name' => 'Test Company',
            'description' => 'Test Description'
        ]);

        $this->assertInstanceOf(Company::class, $company);
        $this->assertEquals('Test Company', $company->name);
    }

    /** @test */
    public function it_can_have_multiple_accounts()
    {
        $company = Company::factory()->create();
        $account1 = $company->accounts()->create(['name' => 'Account 1']);
        $account2 = $company->accounts()->create(['name' => 'Account 2']);

        $this->assertCount(2, $company->accounts);
        $this->assertTrue($company->accounts->contains($account1));
        $this->assertTrue($company->accounts->contains($account2));
    }
}
EOF

# Тест для модели Account
cat > tests/Unit/AccountTest.php << 'EOF'
<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Account;
use App\Models\Company;

class AccountTest extends TestCase
{
    /** @test */
    public function it_belongs_to_a_company()
    {
        $company = Company::create(['name' => 'Test Company']);
        $account = Account::create(['company_id' => $company->id, 'name' => 'Test Account']);

        $this->assertInstanceOf(Company::class, $account->company);
        $this->assertEquals($company->id, $account->company->id);
    }

    /** @test */
    public function it_can_have_tokens()
    {
        $company = Company::create(['name' => 'Test Company']);
        $account = Account::create(['company_id' => $company->id, 'name' => 'Test Account']);

        $token = $account->tokens()->create([
            'api_service_id' => 1,
            'token_type_id' => 1,
            'token_value' => 'test_token',
            'name' => 'Test Token'
        ]);

        $this->assertCount(1, $account->tokens);
        $this->assertEquals('test_token', $account->tokens->first()->token_value);
    }
}
EOF

# Тест для команды создания компании
cat > tests/Feature/CreateCompanyCommandTest.php << 'EOF'
<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Support\Facades\Artisan;

class CreateCompanyCommandTest extends TestCase
{
    /** @test */
    public function it_creates_a_company_via_command()
    {
        $this->artisan('company:create', [
            'name' => 'Command Test Company'
        ])->assertExitCode(0);

        $this->assertDatabaseHas('companies', [
            'name' => 'Command Test Company'
        ]);
    }
}
EOF

echo "Basic tests created in tests/ directory"
