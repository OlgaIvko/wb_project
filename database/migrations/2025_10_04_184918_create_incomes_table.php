<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('incomes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('account_id')->constrained()->onDelete('cascade');
            $table->dateTime('date');
            $table->dateTime('last_change_date');
            $table->string('supplier_article');
            $table->string('tech_size');
            $table->string('barcode');
            $table->integer('quantity');
            $table->decimal('total_price', 10, 2);
            $table->dateTime('date_close');
            $table->string('warehouse_name');
            $table->bigInteger('nm_id');
            $table->string('status');
            $table->bigInteger('income_id');
            $table->timestamps();

            $table->index(['account_id', 'date']);
            $table->index(['date']);
            $table->unique(['account_id', 'income_id'], 'unique_income');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('incomes');
    }
};
