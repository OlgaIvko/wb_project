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
