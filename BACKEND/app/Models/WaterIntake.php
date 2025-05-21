<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WaterIntake extends Model
{
    use HasFactory;

    protected $primaryKey = 'water_intake_id';
    protected $fillable = ['jumlah_ml'];
    public $timestamps = true;
}
