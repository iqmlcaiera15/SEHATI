<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PredictionSeeder extends Seeder
{
    public function run()
    {
        $tekanan_darah = ['normal', 'rendah', 'tinggi'];
        $riwayat_persalinan = ['belum pernah melahirkan', 'normal', 'caesar'];
        $riwayat_kesehatan_ibu = ['tidak ada', 'anemia', 'ginjal', 'diabetes', 'kehamilan lewat waktu', 'preeklampsia', 'obesitas', 'mata minus', 'jantung', 'usus buntu'];
        $posisi_janin = ['normal', 'lintang', 'sungsang'];
        $kondisi_kesehatan_janin = ['tidak ada', 'bayi besar', 'prematur', 'asfiksia', 'distosia batu', 'fetal distress', 'gemelli', 'IUGR', 'letak dahi', 'lilitan tali pusar'];
        $hasil_prediksi = ['Persalinan Normal', 'Persalinan Caesar'];

        for ($i = 0; $i < 10; $i++) {
            DB::table('predictions')->insert([
                'usia_ibu' => rand(18, 40), // Usia ibu antara 18 - 40 tahun
                'tekanan_darah' => $tekanan_darah[array_rand($tekanan_darah)],
                'riwayat_persalinan' => $riwayat_persalinan[array_rand($riwayat_persalinan)],
                'riwayat_kesehatan_ibu' => $riwayat_kesehatan_ibu[array_rand($riwayat_kesehatan_ibu)],
                'posisi_janin' => $posisi_janin[array_rand($posisi_janin)],
                'kondisi_kesehatan_janin' => $kondisi_kesehatan_janin[array_rand($kondisi_kesehatan_janin)],
                'hasil_prediksi' => $hasil_prediksi[array_rand($hasil_prediksi)]
            ]);
        }
    }
}
