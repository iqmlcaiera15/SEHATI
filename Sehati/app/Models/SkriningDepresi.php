<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SkriningDepresi extends Model
{
    use HasFactory;

    protected $table = 'skrining_depresi';

    protected $fillable = [
        'user_id',
        'whooley_1',
        'whooley_2',
        'whooley_result',
        'epds_score',
        'umur',
        'jumlah_kelahiran',
        'jumlah_keguguran',
        'status_bekerja',
        'tanggal_evaluasi',
        'depression_status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
