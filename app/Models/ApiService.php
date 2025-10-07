<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ApiService extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'base_url', 'supported_token_types'];

    protected $casts = [
        'supported_token_types' => 'array',
    ];
}
