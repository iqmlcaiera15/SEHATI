<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
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
                    'kategori' => 'Buah',
                    'nama_makanan' => 'Pisang',
                    'deskripsi' => 'Kaya akan kalium dan serat, baik untuk pencernaan.',
                    'cocok' => 'ibu hamil',
                ],
                [
                    'kategori' => 'Sayuran',
                    'nama_makanan' => 'Bayam',
                    'deskripsi' => 'Mengandung zat besi dan folat, penting untuk perkembangan janin.',
                    'cocok' => 'ibu hamil',
                ],
                [
                    'kategori' => 'Protein',
                    'nama_makanan' => 'Telur Rebus',
                    'deskripsi' => 'Sumber protein dan kolin yang baik untuk otak janin.',
                    'cocok' => 'ibu hamil',
                ],
                [
                    'kategori' => 'Buah',
                    'nama_makanan' => 'Alpukat',
                    'deskripsi' => 'Kaya lemak sehat dan folat, baik untuk perkembangan otak bayi.',
                    'cocok' => 'ibu menyusui',
                ],
                [
                    'kategori' => 'Sayuran',
                    'nama_makanan' => 'Brokoli',
                    'deskripsi' => 'Mengandung kalsium dan vitamin C, baik untuk produksi ASI.',
                    'cocok' => 'ibu menyusui',
                ],
                [
                    'kategori' => 'Protein',
                    'nama_makanan' => 'Ikan Salmon',
                    'deskripsi' => 'Kaya omega-3, baik untuk perkembangan otak bayi.',
                    'cocok' => 'ibu menyusui',
                ],
                [
                    'kategori' => 'Buah',
                    'nama_makanan' => 'Apel',
                    'deskripsi' => 'Mudah dicerna dan kaya serat, cocok untuk bayi.',
                    'cocok' => 'bayi',
                ],
                [
                    'kategori' => 'Sayuran',
                    'nama_makanan' => 'Wortel',
                    'deskripsi' => 'Kaya vitamin A, baik untuk penglihatan bayi.',
                    'cocok' => 'bayi',
                ],
                [
                    'kategori' => 'Protein',
                    'nama_makanan' => 'Daging Ayam',
                    'deskripsi' => 'Sumber protein yang baik untuk pertumbuhan bayi.',
                    'cocok' => 'bayi',
                ],
                [
                    'kategori' => 'Buah',
                    'nama_makanan' => 'Pir',
                    'deskripsi' => 'Lembut dan mudah dicerna, cocok untuk bayi.',
                    'cocok' => 'bayi',
                ],
        ];

        foreach ($Makanans as $Makanan)
        {
            DB::table('saran_makanan')->insert($Makanan);
        }
    }
}
