<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FetalMonitoring extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama_calon_bayi',
        'berat_ibu',
        'hpht',
        'hpl',
        'bayi_kembar'
    ];
}
