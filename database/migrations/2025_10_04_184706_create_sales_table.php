<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sales', function (Blueprint $table) {
            $table->id();
            $table->foreignId('account_id')->constrained()->onDelete('cascade');
            $table->dateTime('date');
            $table->dateTime('last_change_date');
            $table->string('supplier_article');
            $table->string('tech_size');
            $table->string('barcode');
            $table->decimal('total_price', 10, 2);
            $table->integer('discount_percent');
            $table->string('warehouse_name');
            $table->string('country_name');
            $table->string('oblast_okrug_name');
            $table->string('region_name');
            $table->bigInteger('income_id');
            $table->string('sale_id');
            $table->bigInteger('odid');
            $table->bigInteger('spp');
            $table->decimal('for_pay', 10, 2);
            $table->decimal('finished_price', 10, 2);
            $table->decimal('price_with_disc', 10, 2);
            $table->bigInteger('nm_id');
            $table->string('subject');
            $table->string('category');
            $table->string('brand');
            $table->boolean('is_storno')->default(false);
            $table->timestamps();

            $table->index(['account_id', 'date']);
            $table->index(['date']);
            $table->unique(['account_id', 'sale_id', 'odid'], 'unique_sale');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sales');
    }
};
