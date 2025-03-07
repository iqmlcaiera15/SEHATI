<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PostpartumSaranSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $Sarans = [
            [
                'postpartum' => 'Menjaga Kesehatan Ibu',
                'deskripsi' => 'Menjaga kesehatan ibu hamil dengan memberikan asupan nutrisi yang cukup, istirahat yang cukup, dan menghindari stres.',
                'hari' => 5,
            ],
            [
                'postpartum' => 'Perawatan Luka Jahitan',
                'deskripsi' => 'Merawat luka jahitan dengan membersihkan area tersebut secara rutin dan menghindari aktivitas berat.',
                'hari' => 3,
            ],
            [
                'postpartum' => 'Menyusui yang Benar',
                'deskripsi' => 'Menyusui bayi dengan posisi yang benar dan memastikan bayi mendapatkan ASI eksklusif.',
                'hari' => 1,
            ],
            [
                'postpartum' => 'Pemulihan Fisik',
                'deskripsi' => 'Melakukan latihan ringan seperti jalan kaki untuk membantu pemulihan fisik setelah melahirkan.',
                'hari' => 7,
            ],
            [
                'postpartum' => 'Menjaga Kesehatan Mental',
                'deskripsi' => 'Menjaga kesehatan mental dengan berbicara kepada keluarga atau profesional jika merasa tertekan.',
                'hari' => 10,
            ],
            [
                'postpartum' => 'Mengonsumsi Makanan Bergizi',
                'deskripsi' => 'Mengonsumsi makanan bergizi seperti sayuran, buah, dan protein untuk pemulihan tubuh.',
                'hari' => 2,
            ],
            [
                'postpartum' => 'Hindari Aktivitas Berat',
                'deskripsi' => 'Menghindari aktivitas berat seperti mengangkat benda berat selama masa pemulihan.',
                'hari' => 4,
            ],
            [
                'postpartum' => 'Periksa Kesehatan Rutin',
                'deskripsi' => 'Melakukan pemeriksaan kesehatan rutin ke dokter untuk memastikan kondisi tubuh pulih dengan baik.',
                'hari' => 14,
            ],
            [
                'postpartum' => 'Istirahat yang Cukup',
                'deskripsi' => 'Memastikan ibu mendapatkan istirahat yang cukup untuk pemulihan energi dan kesehatan.',
                'hari' => 6,
            ],
            [
                'postpartum' => 'Hidrasi yang Cukup',
                'deskripsi' => 'Minum air putih yang cukup untuk menjaga tubuh tetap terhidrasi dan membantu produksi ASI.',
                'hari' => 1,
            ],
        ];

        foreach ($Sarans as $Saran)
        {
            DB::table('postpartum')->insert($Saran);
        }
    }
}
