<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Product; // Import model Product
use Illuminate\Support\Facades\DB; // Jika ingin menggunakan DB Facade

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Hapus data lama jika ada (opsional, hati-hati jika sudah ada data penting)
        // Product::truncate(); // atau DB::table('products')->delete();

        Product::create([
            'produk' => 'Vitamin C Super',
            'deskripsi' => 'Suplemen Vitamin C dosis tinggi untuk menjaga daya tahan tubuh.',
            'harga' => 75000.00,
            'gambar' => 'iconshttps://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg',
            'link' => 'https://shopee.co.id/Mmflight-Stroller-Baby-Lipat-Traveling-Kereta-Dorong-Bayi-2-Arah-Cabin-Size-i.899195971.19162760795?sp_atk=81f88bd3-2427-40c0-8bfa-adbab417c936&xptdk=81f88bd3-2427-40c0-8bfa-adbab417c936'
        ]);

        Product::create([
            'produk' => 'Obat Batuk Herbal Anak',
            'deskripsi' => 'Sirup obat batuk herbal alami, aman untuk anak-anak usia 2 tahun ke atas.',
            'harga' => 45000.00,
            'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg',
            'link' => 'https://shopee.co.id/Mmflight-Stroller-Baby-Lipat-Traveling-Kereta-Dorong-Bayi-2-Arah-Cabin-Size-i.899195971.19162760795?sp_atk=81f88bd3-2427-40c0-8bfa-adbab417c936&xptdk=81f88bd3-2427-40c0-8bfa-adbab417c936'
        ]);

        Product::create([
            'produk' => 'Stroller',
            'deskripsi' => 'Masker medis standar N95 untuk perlindungan maksimal dari virus dan bakteri.',
            'harga' => 200000.00,
            'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg',
            'link' => 'https://shopee.co.id/Mmflight-Stroller-Baby-Lipat-Traveling-Kereta-Dorong-Bayi-2-Arah-Cabin-Size-i.899195971.19162760795?sp_atk=81f88bd3-2427-40c0-8bfa-adbab417c936&xptdk=81f88bd3-2427-40c0-8bfa-adbab417c936'
        ]);

        Product::create([
            'produk' => 'Hand Sanitizer Antiseptik',
            'deskripsi' => 'Pembersih tangan antiseptik dengan kandungan alkohol 70%, efektif membunuh kuman.',
            'harga' => 25000.00,
            'gambar' => 'https://amazon-datazone-sehatiapp.s3.ap-southeast-1.amazonaws.com/rekomenmakanan/ikan_salmon.jpg',
            'link' => 'https://shopee.co.id/Mmflight-Stroller-Baby-Lipat-Traveling-Kereta-Dorong-Bayi-2-Arah-Cabin-Size-i.899195971.19162760795?sp_atk=81f88bd3-2427-40c0-8bfa-adbab417c936&xptdk=81f88bd3-2427-40c0-8bfa-adbab417c936'
        ]);

        // Anda bisa menambahkan lebih banyak produk di sini
    }
}