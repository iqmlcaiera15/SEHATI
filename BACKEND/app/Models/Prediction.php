<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Prediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',                    // Tambahkan ini agar relasi user bisa tersimpan
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
     * Opsional: Jika kolom faktor disimpan dalam bentuk JSON,
     * aktifkan casting berikut agar otomatis menjadi array saat diakses.
     */
    protected $casts = [
        'faktor' => 'array',
    ];
}
