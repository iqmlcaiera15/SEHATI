<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SaranMakananSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $Makanans = [
            [
                'nama' => 'Pisang',
                'deskripsi' => 'Kaya akan kalium dan serat, baik untuk pencernaan.',
                'target_makanan' => ['Hamil'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Bayam',
                'deskripsi' => 'Mengandung zat besi dan folat, penting untuk perkembangan janin.',
                'target_makanan' => ['Hamil'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Telur Rebus',
                'deskripsi' => 'Sumber protein dan kolin yang baik untuk otak janin.',
                'target_makanan' => ['Hamil'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Alpukat',
                'deskripsi' => 'Kaya lemak sehat dan folat, baik untuk perkembangan otak bayi.',
                'target_makanan' => ['Menyusui'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Brokoli',
                'deskripsi' => 'Mengandung kalsium dan vitamin C, baik untuk produksi ASI.',
                'target_makanan' => ['Menyusui'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Ikan Salmon',
                'deskripsi' => 'Kaya omega-3, baik untuk perkembangan otak bayi.',
                'target_makanan' => ['Menyusui'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Apel',
                'deskripsi' => 'Mudah dicerna dan kaya serat, cocok untuk bayi.',
                'target_makanan' => ['Bayi'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Wortel',
                'deskripsi' => 'Kaya vitamin A, baik untuk penglihatan bayi.',
                'target_makanan' => ['Bayi'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Daging Ayam',
                'deskripsi' => 'Sumber protein yang baik untuk pertumbuhan bayi.',
                'target_makanan' => ['Bayi'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
            [
                'nama' => 'Pir',
                'deskripsi' => 'Lembut dan mudah dicerna, cocok untuk bayi.',
                'target_makanan' => ['Bayi'],
                'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/cara-mengawinkan-ayam-bangkok.webp',
            ],
        ];

        foreach ($Makanans as $makanan) {
            DB::table('rekomendasi_makanan')->insert([
                'nama' => $makanan['nama'],
                'deskripsi' => $makanan['deskripsi'],
                'gambar' => $makanan['gambar'],
                'target_makanan' => json_encode($makanan['target_makanan']),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
