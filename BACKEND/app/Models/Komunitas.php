<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class DeteksiPenyakit extends Model
{
    use HasFactory;

    protected $table = 'komunitas';
    protected $primaryKey = 'post_id';

    protected $fillable = [
        'user_id', 
        'judul', 
        'deskripsi', 
        'tekanan_darah', 
        'komen', 
        'likes'
    ];


}
