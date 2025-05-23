<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SaranMakananSeeder extends Seeder
{
    public function run()
    {
        DB::table('rekomendasi_makanan')->insert([
            [
                'nama' => 'Sayur Bayam',
                'deskripsi' => 'Sayur bayam kaya akan zat besi dan sangat baik untuk ibu hamil dan menyusui.',
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
                'target_makanan' => json_encode(['Hamil', 'Menyusui']),
            ],
            [
                'nama' => 'Ikan Salmon',
                'deskripsi' => 'Ikan salmon mengandung omega-3 yang bermanfaat untuk perkembangan otak janin.',
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
                'target_makanan' => json_encode(['Hamil']),
            ],
            [
                'nama' => 'Susu Almond',
                'deskripsi' => 'Susu almond adalah alternatif susu yang menyehatkan bagi ibu menyusui.',
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
                'target_makanan' => json_encode(['Menyusui']),
            ],
        ]);
    }
}
