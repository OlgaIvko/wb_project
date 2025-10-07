<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('api_services', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('base_url');
            $table->json('supported_token_types');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('api_services');
    }
};
