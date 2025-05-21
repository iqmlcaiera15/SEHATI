<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KickCounter extends Model
{
    use HasFactory;

    protected $fillable = [
        'kick_count', 
        'recorded_at',
        'duration',
    ];
}