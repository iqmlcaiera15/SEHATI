<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\WaterIntake;
use Carbon\Carbon;

class WaterIntakeSeeder extends Seeder
{
    public function run()
    {
        // Tambahkan data untuk 7 hari terakhir
        for ($i = 6; $i >= 0; $i--) {
            WaterIntake::create([
                'jumlah_ml' => 250 * rand(2, 8), // 2 - 8 gelas per hari (500ml - 2000ml)
                'created_at' => Carbon::now()->subDays($i),
                'updated_at' => Carbon::now()->subDays($i),
            ]);
        }
    }
}
