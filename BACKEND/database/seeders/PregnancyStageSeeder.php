<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PregnancyStageSeeder extends Seeder
{
    public function run()
    {
        $stages = [
            [
                'minggu_ke' => 1,
                'bentuk_janin' => 'Belum berbentuk (masih berupa sel kecil)',
                'panjang_badan' => '-',
                'berat_badan' => '-',
                'perkembangan' => 'Proses pembuahan dan implantasi embrio di dinding rahim',
                'rekomendasi' => 'Konsumsi makanan bergizi, minum asam folat, dan istirahat cukup'
            ],
            [
                'minggu_ke' => 2,
                'bentuk_janin' => 'Belum berbentuk (masih berupa sel kecil)',
                'panjang_badan' => '-',
                'berat_badan' => '-',
                'perkembangan' => 'Proses pembuahan dan implantasi embrio di dinding rahim',
                'rekomendasi' => 'Konsumsi makanan bergizi, minum asam folat, dan istirahat cukup'
            ],
            [
                'minggu_ke' => 3,
                'bentuk_janin' => 'biji chia',
                'panjang_badan' => '0,15 mm',
                'berat_badan' => '-',
                'perkembangan' => 'Embrio mulai membelah menjadi banyak sel',
                'rekomendasi' => 'Jaga asupan cairan tubuh dan hindari stres berat'
            ],
            [
                'minggu_ke' => 4,
                'bentuk_janin' => 'biji cabe',
                'panjang_badan' => '0,4 mm',
                'berat_badan' => '-',
                'perkembangan' => 'Kantung kehamilan mulai terbentuk di rahim',
                'rekomendasi' => 'Lakukan tes kehamilan dan konsultasi dengan bidan atau dokter'
            ],
            [
                'minggu_ke' => 5,
                'bentuk_janin' => 'biji wijen',
                'panjang_badan' => '1–2 mm',
                'berat_badan' => '-',
                'perkembangan' => 'Tabung saraf cikal bakal otak dan tulang belakang mulai terbentuk',
                'rekomendasi' => 'Lanjutkan konsumsi asam folat dan hindari bahan kimia berbahaya'
            ],
            [
                'minggu_ke' => 6,
                'bentuk_janin' => 'kacang polong',
                'panjang_badan' => '4–5 mm',
                'berat_badan' => '-',
                'perkembangan' => 'Jantung mulai berdetak dan sistem peredaran darah mulai berfungsi',
                'rekomendasi' => 'Kurangi kafein dan hindari rokok atau alkohol'
            ],
            [
                'minggu_ke' => 7,
                'bentuk_janin' => 'blueberry',
                'panjang_badan' => '1 cm',
                'berat_badan' => '0,8 gram',
                'perkembangan' => 'Tunas tangan dan kaki mulai terlihat',
                'rekomendasi' => 'Konsumsi protein seperti tahu, tempe, telur, atau ikan'
            ],
            [
                'minggu_ke' => 8,
                'bentuk_janin' => 'raspberry',
                'panjang_badan' => '1,6 cm',
                'berat_badan' => '1 gram',
                'perkembangan' => 'Organ penting mulai terbentuk, bayi mulai bergerak walau belum terasa',
                'rekomendasi' => 'Pastikan asupan kalsium cukup, bisa dari susu atau produk olahan'
            ],
            [
                'minggu_ke' => 9,
                'bentuk_janin' => 'ceri',
                'panjang_badan' => '2,3 cm',
                'berat_badan' => '2 gram',
                'perkembangan' => 'Jari-jari tangan dan kaki mulai terbentuk',
                'rekomendasi' => 'Istirahat cukup, kurangi aktivitas berat'
            ],
            [
                'minggu_ke' => 10,
                'bentuk_janin' => 'plum kecil',
                'panjang_badan' => '3,1 cm',
                'berat_badan' => '4 gram',
                'perkembangan' => 'Organ vital seperti ginjal, usus, dan otak semakin berkembang',
                'rekomendasi' => 'Konsumsi banyak buah dan sayur untuk mendukung perkembangan organ bayi'
            ],
            [
                'minggu_ke' => 11,
                'bentuk_janin' => 'leci',
                'panjang_badan' => '4,1 cm',
                'berat_badan' => '7 gram',
                'perkembangan' => 'Wajah bayi semakin terbentuk; telinga, hidung, dan mulut mulai jelas',
                'rekomendasi' => 'Mulai olahraga ringan seperti jalan kaki dan hindari posisi tidur telentang terlalu lama'
            ],
            [
                'minggu_ke' => 12,
                'bentuk_janin' => 'lemon kecil',
                'panjang_badan' => '5,4 cm',
                'berat_badan' => '14 gram',
                'perkembangan' => 'Semua organ utama telah terbentuk; bayi bisa membuka dan menutup mulut',
                'rekomendasi' => 'Tetap kontrol rutin ke fasilitas kesehatan untuk cek kehamilan dan kondisi janin'
            ],
            [
                'minggu_ke' => 13,
                'bentuk_janin' => 'lemon',
                'panjang_badan' => '7,4 cm',
                'berat_badan' => '23 gram',
                'perkembangan' => 'Sidik jari mulai terbentuk, dan tubuh bayi mulai seimbang dengan kepala',
                'rekomendasi' => 'Mulai konsumsi makanan tinggi zat besi untuk cegah anemia'
            ],
            [
                'minggu_ke' => 14,
                'bentuk_janin' => 'jambu biji',
                'panjang_badan' => '8,7 cm',
                'berat_badan' => '43 gram',
                'perkembangan' => 'Bayi bisa membuat ekspresi wajah seperti cemberut atau senyum',
                'rekomendasi' => 'Konsumsi protein, vitamin C, dan hindari makanan mentah'
            ],
            [
                'minggu_ke' => 15,
                'bentuk_janin' => 'pir',
                'panjang_badan' => '10,1 cm',
                'berat_badan' => '70 gram',
                'perkembangan' => 'Tulang-tulang mengeras, dan bayi mulai belajar menghisap ibu jarinya',
                'rekomendasi' => 'Rutin peregangan ringan dan minum cukup air'
            ],
            [
                'minggu_ke' => 16,
                'bentuk_janin' => 'alpukat',
                'panjang_badan' => '11,6 cm',
                'berat_badan' => '100 gram',
                'perkembangan' => 'Gerakan bayi mulai bisa dirasakan oleh sebagian ibu',
                'rekomendasi' => 'Perbanyak sayur hijau dan konsumsi makanan kaya serat'
            ],
            [
                'minggu_ke' => 17,
                'bentuk_janin' => 'paprika',
                'panjang_badan' => '13 cm',
                'berat_badan' => '140 gram',
                'perkembangan' => 'Lemak pelindung tubuh mulai terbentuk',
                'rekomendasi' => 'Gunakan pakaian longgar dan nyaman untuk mendukung perubahan tubuh'
            ],
            [
                'minggu_ke' => 18,
                'bentuk_janin' => 'ubi jalar',
                'panjang_badan' => '14,2 cm',
                'berat_badan' => '190 gram',
                'perkembangan' => 'Telinga bayi sudah mendengar suara dari luar rahim',
                'rekomendasi' => 'Sering berbicara atau memutarkan musik lembut untuk bayi'
            ],
            [
                'minggu_ke' => 19,
                'bentuk_janin' => 'mangga',
                'panjang_badan' => '15,3 cm',
                'berat_badan' => '240 gram',
                'perkembangan' => 'Verniks (lapisan putih pelindung kulit) mulai menutupi tubuh bayi',
                'rekomendasi' => 'Jangan lupa rutin kontrol ke bidan atau dokter'
            ],
            [
                'minggu_ke' => 20,
                'bentuk_janin' => 'labu siam',
                'panjang_badan' => '16,4 cm',
                'berat_badan' => '300 gram',
                'perkembangan' => 'Organ reproduksi bayi sudah berkembang sempurna',
                'rekomendasi' => 'Mulai siapkan catatan perkembangan kehamilan dan gerakan bayi'
            ],
            [
                'minggu_ke' => 21,
                'bentuk_janin' => 'pisang',
                'panjang_badan' => '26,7 cm',
                'berat_badan' => '360 gram',
                'perkembangan' => 'Sistem pencernaan bayi mulai berfungsi',
                'rekomendasi' => 'Konsumsi makanan tinggi kalsium dan magnesium'
            ],
            [
                'minggu_ke' => 22,
                'bentuk_janin' => 'pepaya',
                'panjang_badan' => '27,8 cm',
                'berat_badan' => '430 gram',
                'perkembangan' => 'Bayi mulai merasakan rasa manis dari air ketuban',
                'rekomendasi' => 'Tetap aktif bergerak, misalnya jalan santai'
            ],
            [
                'minggu_ke' => 23,
                'bentuk_janin' => 'buah naga',
                'panjang_badan' => '28,9 cm',
                'berat_badan' => '500 gram',
                'perkembangan' => 'Tulang bayi semakin kuat dan organ paru-paru mulai berkembang',
                'rekomendasi' => 'Penuhi kebutuhan protein harian untuk dukung perkembangan'
            ],
            [
                'minggu_ke' => 24,
                'bentuk_janin' => 'jeruk bali',
                'panjang_badan' => '30 cm',
                'berat_badan' => '600 gram',
                'perkembangan' => 'Bayi mulai tidur dan bangun dalam pola tertentu',
                'rekomendasi' => 'Mulai pelajari tanda-tanda persalinan dini'
            ],
            [
                'minggu_ke' => 25,
                'bentuk_janin' => 'blewah',
                'panjang_badan' => '34,6 cm',
                'berat_badan' => '660 gram',
                'perkembangan' => 'Rambut halus (lanugo) menutupi tubuh bayi',
                'rekomendasi' => 'Konsumsi makanan yang kaya DHA seperti ikan laut'
            ],
            [
                'minggu_ke' => 26,
                'bentuk_janin' => 'kembang kol',
                'panjang_badan' => '35,6 cm',
                'berat_badan' => '760 gram',
                'perkembangan' => 'Mata bayi mulai bisa membuka',
                'rekomendasi' => 'Kurangi berdiri terlalu lama dan banyak beristirahat'
            ],
            [
                'minggu_ke' => 27,
                'bentuk_janin' => 'selada',
                'panjang_badan' => '36,6 cm',
                'berat_badan' => '875 gram',
                'perkembangan' => 'Otak bayi berkembang sangat cepat; sistem saraf semakin sempurna',
                'rekomendasi' => 'Perbanyak konsumsi makanan kaya omega-3 untuk perkembangan otak'
            ],
            [
                'minggu_ke' => 28,
                'bentuk_janin' => 'sawi putih',
                'panjang_badan' => '37,6 cm',
                'berat_badan' => '1.000 gram',
                'perkembangan' => 'Bayi sudah bisa membuka mata dan berkedip',
                'rekomendasi' => 'Perbanyak istirahat, tidur miring ke kiri untuk melancarkan aliran darah'
            ],
            [
                'minggu_ke' => 29,
                'bentuk_janin' => 'labu',
                'panjang_badan' => '38,6 cm',
                'berat_badan' => '1.150 gram',
                'perkembangan' => 'Paru-paru dan otot bayi terus berkembang',
                'rekomendasi' => 'Mulai pelajari tanda-tanda persalinan dan siapkan perlengkapan melahirkan'
            ],
            [
                'minggu_ke' => 30,
                'bentuk_janin' => 'kubis',
                'panjang_badan' => '39,9 cm',
                'berat_badan' => '1.300 gram',
                'perkembangan' => 'Lapisan lemak tubuh bertambah, bayi makin berisi',
                'rekomendasi' => 'Cukupi asupan protein dan vitamin D untuk kekuatan tulang bayi'
            ],
            [
                'minggu_ke' => 31,
                'bentuk_janin' => 'kelapa',
                'panjang_badan' => '41,1 cm',
                'berat_badan' => '1.500 gram',
                'perkembangan' => 'Lima indera bayi bekerja sempurna, bayi bisa bermimpi',
                'rekomendasi' => 'Seringlah peregangan ringan untuk mengurangi pegal'
            ],
            [
                'minggu_ke' => 32,
                'bentuk_janin' => 'melon',
                'panjang_badan' => '42,4 cm',
                'berat_badan' => '1.700 gram',
                'perkembangan' => 'Bayi mulai mengambil posisi kepala ke bawah',
                'rekomendasi' => 'Persiapkan mental untuk persalinan, sering diskusi dengan bidan atau dokter'
            ],
            [
                'minggu_ke' => 33,
                'bentuk_janin' => 'nanas',
                'panjang_badan' => '43,7 cm',
                'berat_badan' => '1.900 gram',
                'perkembangan' => 'Otak bayi berkembang sangat cepat, tulang-tulang makin kuat',
                'rekomendasi' => 'Perbanyak makanan bergizi dan tetap jalani aktivitas ringan'
            ],
            [
                'minggu_ke' => 34,
                'bentuk_janin' => 'labu air',
                'panjang_badan' => '45 cm',
                'berat_badan' => '2.100 gram',
                'perkembangan' => 'Sistem kekebalan tubuh bayi makin kuat',
                'rekomendasi' => 'Rutin minum air putih dan jaga pola makan sehat'
            ],
            [
                'minggu_ke' => 35,
                'bentuk_janin' => 'pepaya',
                'panjang_badan' => '46,2 cm',
                'berat_badan' => '2.400 gram',
                'perkembangan' => 'Lemak di tubuh bayi bertambah, membuat kulitnya halus',
                'rekomendasi' => 'Mulai latihan pernapasan untuk persiapan melahirkan'
            ],
            [
                'minggu_ke' => 36,
                'bentuk_janin' => 'timun suri',
                'panjang_badan' => '47,4 cm',
                'berat_badan' => '2.600 gram',
                'perkembangan' => 'Bayi sudah memenuhi hampir seluruh ruang rahim',
                'rekomendasi' => 'Perbanyak beristirahat, hindari berdiri terlalu lama'
            ],
            [
                'minggu_ke' => 37,
                'bentuk_janin' => 'durian',
                'panjang_badan' => '48,6 cm',
                'berat_badan' => '2.900 gram',
                'perkembangan' => 'Bayi dinyatakan cukup bulan dan siap lahir kapan saja',
                'rekomendasi' => 'Pastikan tas persalinan sudah siap, sering cek gerakan bayi'
            ],
            [
                'minggu_ke' => 38,
                'bentuk_janin' => 'nangka',
                'panjang_badan' => '49,8 cm',
                'berat_badan' => '3.000 gram',
                'perkembangan' => 'Lemak pipi makin bertambah, bayi terlihat chubby',
                'rekomendasi' => 'Hindari perjalanan jauh, lebih sering di rumah menunggu tanda persalinan'
            ],
            [
                'minggu_ke' => 39,
                'bentuk_janin' => 'cempedak',
                'panjang_badan' => '50,7 cm',
                'berat_badan' => '3.200 gram',
                'perkembangan' => 'Semua organ bayi sudah siap berfungsi di luar rahim',
                'rekomendasi' => 'Nikmati momen akhir kehamilan, tetap relaks dan tenang'
            ],
            [
                'minggu_ke' => 40,
                'bentuk_janin' => 'semangka',
                'panjang_badan' => '51,2 cm',
                'berat_badan' => '3.300 gram',
                'perkembangan' => 'Bayi sudah matang sempurna dan siap dilahirkan',
                'rekomendasi' => 'Tetap aktif bergerak ringan, dan jangan lupa tetap kontrol ke fasilitas kesehatan'
            ],
            [
                'minggu_ke' => 41,
                'bentuk_janin' => 'Bayi',
                'panjang_badan' => '52 cm',
                'berat_badan' => '3.600 gram',
                'perkembangan' => 'Bayi semakin besar, kulit mulai sedikit mengelupas karena berkurangnya cairan ketuban',
                'rekomendasi' => 'Konsultasikan dengan dokter atau bidan jika belum ada tanda persalinan, mungkin akan direncanakan induksi'
            ],
            [
                'minggu_ke' => 42,
                'bentuk_janin' => 'Bayi',
                'panjang_badan' => '53 cm',
                'berat_badan' => '3.800 gram',
                'perkembangan' => 'Bayi semakin besar, kulit mulai sedikit mengelupas karena berkurangnya cairan ketuban',
                'rekomendasi' => 'Konsultasikan dengan dokter atau bidan jika belum ada tanda persalinan, mungkin akan direncanakan induksi'
            ]
        ];
        DB::table('pregnancy_stages')->insert($stages);
    }
}
