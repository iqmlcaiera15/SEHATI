<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Prediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'usia_ibu',
        'tekanan_darah',
        'riwayat_persalinan',
        'posisi_janin',
        'riwayat_kesehatan_ibu',
        'kondisi_kesehatan_janin',
        'metode_persalinan'
    ];
}
