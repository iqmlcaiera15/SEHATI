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
            'gambar' => 'https://via.placeholder.com/400x300.png/0077ff?text=VitaminC',
        ]);

        Product::create([
            'produk' => 'Obat Batuk Herbal Anak',
            'deskripsi' => 'Sirup obat batuk herbal alami, aman untuk anak-anak usia 2 tahun ke atas.',
            'harga' => 45000.00,
            'gambar' => 'https://via.placeholder.com/400x300.png/00aa55?text=ObatBatukAnak',
        ]);

        Product::create([
            'produk' => 'Masker Medis N95 (Box isi 20)',
            'deskripsi' => 'Masker medis standar N95 untuk perlindungan maksimal dari virus dan bakteri.',
            'harga' => 120000.00,
            'gambar' => 'https://via.placeholder.com/400x300.png/ff0000?text=MaskerN95',
        ]);

        Product::create([
            'produk' => 'Hand Sanitizer Antiseptik',
            'deskripsi' => 'Pembersih tangan antiseptik dengan kandungan alkohol 70%, efektif membunuh kuman.',
            'harga' => 25000.00,
            'gambar' => 'https://via.placeholder.com/400x300.png/dd7700?text=HandSanitizer',
        ]);

        // Anda bisa menambahkan lebih banyak produk di sini
    }
}