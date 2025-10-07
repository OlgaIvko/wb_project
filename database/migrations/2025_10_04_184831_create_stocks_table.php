<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('account_id')->constrained()->onDelete('cascade');
            $table->dateTime('date');
            $table->dateTime('last_change_date');
            $table->string('supplier_article');
            $table->string('tech_size');
            $table->string('barcode');
            $table->integer('quantity');
            $table->integer('quantity_full');
            $table->integer('quantity_not_in_orders');
            $table->bigInteger('nm_id');
            $table->string('subject');
            $table->string('category');
            $table->string('brand');
            $table->string('warehouse_name');
            $table->integer('in_way_to_client');
            $table->integer('in_way_from_client');
            $table->timestamps();

            $table->index(['account_id', 'date']);
            $table->index(['date']);
            $table->unique(['account_id', 'nm_id', 'barcode', 'warehouse_name'], 'unique_stock');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stocks');
    }
};
