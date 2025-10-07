<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Исправляем поля в таблице stocks
        Schema::table('stocks', function (Blueprint $table) {
            $table->dateTime('last_change_date')->nullable()->change();
            $table->string('supplier_article')->nullable()->change();
            $table->string('tech_size')->nullable()->change();
            $table->string('subject')->nullable()->change();
            $table->string('category')->nullable()->change();
            $table->string('brand')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('stocks', function (Blueprint $table) {
            $table->dateTime('last_change_date')->nullable(false)->change();
            $table->string('supplier_article')->nullable(false)->change();
            $table->string('tech_size')->nullable(false)->change();
            $table->string('subject')->nullable(false)->change();
            $table->string('category')->nullable(false)->change();
            $table->string('brand')->nullable(false)->change();
        });
    }
};
