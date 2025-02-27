<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PrediksiDepresi extends Model
{
    use HasFactory;

    protected $table = 'prediksi_depresi';

    protected $fillable = [
        'umur',
        'merasa_sedih',
        'mudah_tersinggung',
        'masalah_tidur',
        'masalah_fokus',
        'pola_makan',
        'merasa_bersalah',
        'suicide_attempt',
        'hasil_prediksi'
    ];
}
