<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PostpartumArticlesSeeder extends Seeder
{
    public function run()
    {
        DB::table('postpartum_articles')->insert([
            [
                'judul' => 'Perawatan Diri Setelah Melahirkan',
                'konten' => 'Setelah melahirkan, penting untuk menjaga kebersihan, nutrisi, dan kesehatan mental agar proses pemulihan berjalan optimal.',
                'kategori' => 'Perawatan',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'judul' => 'Tanda-Tanda Baby Blues dan Cara Mengatasinya',
                'konten' => 'Baby blues sering terjadi beberapa hari setelah melahirkan. Ibu perlu memahami gejala seperti mood swing, sedih tanpa sebab, dan mudah marah.',
                'kategori' => 'Kesehatan Mental',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'judul' => 'Nutrisi Penting untuk Ibu Nifas',
                'konten' => 'Selama masa nifas, ibu memerlukan makanan tinggi zat besi, protein, dan vitamin untuk mempercepat pemulihan tubuh.',
                'kategori' => 'Nutrisi',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]
        ]);
    }
}
