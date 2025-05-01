<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use 

class SkorEpds extends Model
{
    use HasFactory;

    protected $table = 'skorepds';

    protected $fillable = [
        'answers',
        'score',
        'hasil_epds',
        'prediksi_depresi_id'
    ];

    protected $casts = [
        'answers' => 'array',
    ];

    public function prediksi()
    {
        return $this->belongsTo(PrediksiDepresi::class, 'prediksi_depresi_id');
    }
}
