<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Stock extends Model
{
    use HasFactory;

    protected $fillable = [
        'account_id',
        'date',
        'last_change_date',
        'supplier_article',
        'tech_size',
        'barcode',
        'quantity',
        'quantity_full',
        'quantity_not_in_orders',
        'nm_id',
        'subject',
        'category',
        'brand',
        'warehouse_name',
        'in_way_to_client',
        'in_way_from_client',
    ];

    protected $casts = [
        'date' => 'datetime',
        'last_change_date' => 'datetime',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }
}
