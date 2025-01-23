<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeteksiPenyakit extends Model
{
    use HasFactory;

    protected $table = 'deteksipenyakit';
    protected $primaryKey = 'deteksi_id';

    protected $fillable = [
        'nama',
        'umur',
        'bmi',
        'tekanan_darah',
        'hemoglobin',
        'hasil_deteksi'
    ];

}
