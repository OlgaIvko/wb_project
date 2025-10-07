<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Sale extends Model
{
    use HasFactory;

    protected $fillable = [
        'account_id',
        'date',
        'last_change_date',
        'supplier_article',
        'tech_size',
        'barcode',
        'total_price',
        'discount_percent',
        'warehouse_name',
        'country_name',
        'oblast_okrug_name',
        'region_name',
        'income_id',
        'sale_id',
        'odid',
        'spp',
        'for_pay',
        'finished_price',
        'price_with_disc',
        'nm_id',
        'subject',
        'category',
        'brand',
        'is_storno',
    ];

    protected $casts = [
        'date' => 'datetime',
        'last_change_date' => 'datetime',
        'total_price' => 'decimal:2',
        'for_pay' => 'decimal:2',
        'finished_price' => 'decimal:2',
        'price_with_disc' => 'decimal:2',
        'is_storno' => 'boolean',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }
}
