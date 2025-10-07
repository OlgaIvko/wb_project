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
