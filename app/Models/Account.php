<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Account extends Model
{
    use HasFactory;

    protected $fillable = ['company_id', 'name', 'is_active'];

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function tokens(): HasMany
    {
        return $this->hasMany(Token::class);
    }

    public function sales(): HasMany
    {
        return $this->hasMany(Sale::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function stocks(): HasMany
    {
        return $this->hasMany(Stock::class);
    }

    public function incomes(): HasMany
    {
        return $this->hasMany(Income::class);
    }

    public function getActiveToken($apiServiceId)
    {
        return $this->tokens()
            ->where('api_service_id', $apiServiceId)
            ->where('is_active', true)
            ->first();
    }
}
