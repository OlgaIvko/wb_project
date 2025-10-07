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
