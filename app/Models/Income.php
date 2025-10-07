<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Income extends Model
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
        'total_price',
        'date_close',
        'warehouse_name',
        'nm_id',
        'status',
        'income_id',
    ];

    protected $casts = [
        'date' => 'datetime',
        'last_change_date' => 'datetime',
        'date_close' => 'datetime',
        'total_price' => 'decimal:2',
    ];

    public function account(): BelongsTo
    {
        return $this->belongsTo(Account::class);
    }
}
