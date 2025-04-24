<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SkorEpds extends Model
{
    use HasFactory;

    protected $table = 'skorepds';

    protected $fillable = [
        'answers',
        'score'
    ];

    protected $casts = [
        'answers' => 'array',
    ];
}
