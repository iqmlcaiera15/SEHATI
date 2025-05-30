<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Prediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'usia_ibu',
        'tekanan_darah',
        'riwayat_persalinan',
        'posisi_janin',
        'riwayat_kesehatan_ibu',
        'kondisi_kesehatan_janin',
        'metode_persalinan',
        'faktor'
    ];

    /**
     * Relasi: Setiap prediksi dimiliki oleh satu user
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Casting otomatis untuk kolom faktor jika disimpan dalam bentuk JSON
     */
    protected $casts = [
        'faktor' => 'array',
    ];
}
